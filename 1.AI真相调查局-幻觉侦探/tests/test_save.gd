# SaveManager 存档契约测试（临时目录注入，不碰真实 user://）
static func run(tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	var sm = tree.root.get_node("SaveManager")
	var base := "user://__test_save_%d" % Time.get_ticks_usec()
	# 保存原始状态
	var orig_path: String = sm.base_path
	var orig_readonly: bool = sm.read_only
	var orig_loaded: bool = sm._loaded

	# 1. MISSING
	_set_dir(sm, base + "/missing")
	var r = sm.ensure_loaded()
	_eq(f, "missing", r.status, SaveLoadResult.Status.MISSING)

	# 2. OK 往返 + save 后重读
	_set_dir(sm, base + "/ok")
	var pp := PlayerProgress.new()
	pp.progress["case_001"] = {"completed": true, "best_score": 87}
	pp.collected_cards.append("card_fc_001")
	_eq(f, "save ok", sm.save(pp), true)
	_set_dir(sm, base + "/ok")
	var r2 = sm.ensure_loaded()
	_eq(f, "ok status", r2.status, SaveLoadResult.Status.OK)
	_eq(f, "ok best", int(r2.progress.progress.get("case_001", {}).get("best_score", 0)), 87)
	_eq(f, "ok card", r2.progress.collected_cards.has("card_fc_001"), true)

	# 3. CORRUPT
	_set_dir(sm, base + "/corrupt")
	var fc := FileAccess.open(base + "/corrupt/save.json", FileAccess.WRITE)
	fc.store_string("not json {{{")
	fc.close()
	var r3 = sm.ensure_loaded()
	_eq(f, "corrupt", r3.status, SaveLoadResult.Status.CORRUPT)

	# 4. FUTURE_VERSION 只读拒绝覆盖
	_set_dir(sm, base + "/future")
	var ff := FileAccess.open(base + "/future/save.json", FileAccess.WRITE)
	ff.store_string(JSON.stringify({"save_version": 999, "settings": {}, "progress": {}}))
	ff.close()
	var r4 = sm.ensure_loaded()
	_eq(f, "future status", r4.status, SaveLoadResult.Status.FUTURE_VERSION)
	_eq(f, "future readonly", sm.read_only, true)
	_eq(f, "future save blocked", sm.save(PlayerProgress.new()), false)

	# 5. 缺 save_version 判 corrupt
	_set_dir(sm, base + "/nover")
	var fn := FileAccess.open(base + "/nover/save.json", FileAccess.WRITE)
	fn.store_string(JSON.stringify({"settings": {}, "progress": {}}))
	fn.close()
	var r5 = sm.ensure_loaded()
	_eq(f, "no version corrupt", r5.status, SaveLoadResult.Status.CORRUPT)

	# 6. set_setting 后 save 不覆盖 progress
	_set_dir(sm, base + "/settings")
	sm._loaded = false
	var r6 = sm.ensure_loaded()
	_eq(f, "settings missing", r6.status, SaveLoadResult.Status.MISSING)
	var pp6 := PlayerProgress.new()
	pp6.progress["case_001"] = {"completed": true, "best_score": 50}
	sm.save(pp6)
	sm.set_setting("volume_master", 0.3)
	sm.save(sm._progress)
	_set_dir(sm, base + "/settings")
	var r7 = sm.ensure_loaded()
	_eq(f, "settings best preserved", int(r7.progress.progress.get("case_001", {}).get("best_score", 0)), 50)
	_eq(f, "settings volume", float(r7.progress.settings.get("volume_master", 1.0)), 0.3)

	# 还原
	sm.base_path = orig_path
	sm.read_only = orig_readonly
	sm._loaded = orig_loaded
	return f


static func _set_dir(sm, dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	sm.base_path = dir
	sm.read_only = false
	sm._loaded = false


static func _eq(f: Array, label: String, got, expected) -> void:
	if got != expected:
		f.append("%s = %s，应 %s" % [label, str(got), str(expected)])
