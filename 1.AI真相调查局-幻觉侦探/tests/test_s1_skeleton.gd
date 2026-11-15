# S1 冒烟测试。契约：static func run(tree: SceneTree) -> Array[String]
# 返回失败消息数组；空数组 = 全部通过。

const MAIN_MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const PLACEHOLDER_SCENES := [
	"res://scenes/case_select/case_select.tscn",
	"res://scenes/briefing/briefing.tscn",
	"res://scenes/investigation/investigation_desk.tscn",
	"res://scenes/verdict/final_verdict.tscn",
	"res://scenes/debrief/results.tscn",
	"res://scenes/debrief/debrief.tscn",
	"res://scenes/knowledge/collection.tscn",
	"res://scenes/settings/settings.tscn",
]


static func run(tree: SceneTree) -> Array[String]:
	var failures: Array[String] = []
	failures.append_array(_check_project_settings())
	failures.append_array(_check_theme())
	failures.append_array(_check_dtos())
	failures.append_array(_check_autoloads(tree.root))
	failures.append_array(_check_page_registry(tree.root))
	failures.append_array(_check_scenes())
	return failures


static func _check_project_settings() -> Array[String]:
	var f: Array[String] = []
	var checks := [
		["display/window/size/viewport_width", 1280],
		["display/window/size/viewport_height", 720],
		["display/window/stretch/mode", "canvas_items"],
		["display/window/stretch/aspect", "keep"],
		["rendering/renderer/rendering_method", "gl_compatibility"],
	]
	for c in checks:
		var actual = ProjectSettings.get_setting(c[0])
		if actual != c[1]:
			f.append("ProjectSettings %s = %s，应为 %s" % [c[0], str(actual), str(c[1])])
	return f


static func _check_theme() -> Array[String]:
	var f: Array[String] = []
	var theme: Theme = load("res://assets/ui/theme.tres")
	if theme == null:
		f.append("theme.tres 无法加载")
	else:
		if theme.default_font == null:
			f.append("theme.tres 缺 default_font")
		if theme.default_font_size != 16:
			f.append("theme.tres default_font_size 应为 16，实际 %d" % theme.default_font_size)
	return f


static func _check_dtos() -> Array[String]:
	var f: Array[String] = []
	var pp := PlayerProgress.new()
	if pp.save_version != 2:
		f.append("PlayerProgress.save_version 应为 2")
	if pp.settings.get("volume_master") != 0.8 or pp.settings.get("volume_music") != 0.6 \
			or pp.settings.get("font_scale") != 1.0 or pp.settings.get("window_mode") != "windowed":
		f.append("PlayerProgress 默认 settings 不正确: %s" % str(pp.settings))
	var pp2 := PlayerProgress.from_dict(pp.to_dict())
	if pp2.save_version != 2 or pp2.settings.get("volume_master") != 0.8:
		f.append("PlayerProgress 往返序列化失败")
	if CaseLoadResult.failure([]).ok != false:
		f.append("CaseLoadResult.failure 应为 ok=false")
	if CaseLoadResult.success(null).ok != true:
		f.append("CaseLoadResult.success 应为 ok=true")
	if not CaseCatalog.new().cases.is_empty():
		f.append("CaseCatalog 默认应为空")
	return f


static func _check_autoloads(root: Node) -> Array[String]:
	var f: Array[String] = []
	var sm := root.get_node_or_null("SaveManager")
	var cl := root.get_node_or_null("ContentLoader")
	var gf := root.get_node_or_null("GameFlow")
	if sm == null or cl == null or gf == null:
		f.append("SaveManager/ContentLoader/GameFlow autoload 未全部加载")
		return f
	if not (sm.get_index() < cl.get_index() and cl.get_index() < gf.get_index()):
		f.append("autoload 顺序错误（应为 SaveManager < ContentLoader < GameFlow）")
	if sm.get_setting("volume_master") != 0.8 or sm.get_setting("volume_music") != 0.6 \
			or sm.get_setting("font_scale") != 1.0 or sm.get_setting("window_mode") != "windowed":
		f.append("SaveManager 设置默认值不正确")
	if sm.get_setting("nonexistent_key") != null:
		f.append("未知设置键应返回 null")
	sm.set_setting("volume_master", 0.5)
	if sm.get_setting("volume_master") != 0.5:
		f.append("set_setting 未生效")
	sm.set_setting("volume_master", 0.8)
	if not cl.get_catalog().cases.is_empty():
		f.append("get_catalog 应为空")
	if cl.load_case("x").ok:
		f.append("load_case(不存在) 应 ok=false")
	if cl.get_knowledge_cards().get("cards", null) == null:
		f.append("get_knowledge_cards 应返回 {cards:[]}")
	if gf._settings_cache != 0.8:
		f.append("GameFlow._settings_cache 应为 0.8（autoload 顺序验证失败）")
	if gf._catalog_cache == null:
		f.append("GameFlow._catalog_cache 不应为 null")
	return f


static func _check_page_registry(root: Node) -> Array[String]:
	var f: Array[String] = []
	var gf := root.get_node_or_null("GameFlow")
	if gf == null:
		f.append("GameFlow 未加载")
		return f
	if gf.PAGE_SCENES.size() != 9:
		f.append("PAGE_SCENES 应有 9 项，实际 %d" % gf.PAGE_SCENES.size())
	for page in gf.PAGE_SCENES:
		if not ResourceLoader.exists(gf.PAGE_SCENES[page]):
			f.append("页面路径不存在: %s" % gf.PAGE_SCENES[page])
	if not gf.can_goto(gf.Page.MAIN_MENU):
		f.append("can_goto(MAIN_MENU) 应为 true")
	if gf.can_goto(999):
		f.append("can_goto(999) 应为 false")
	if gf.goto(999):
		f.append("goto(999) 应返回 false")
	return f


static func _check_scenes() -> Array[String]:
	var f: Array[String] = []
	f.append_array(_check_scene_nodes(MAIN_MENU_SCENE, ["StartButton", "CollectionButton", "SettingsButton", "QuitButton", "FooterLabel", "ProgressLabel"]))
	for p in PLACEHOLDER_SCENES:
		f.append_array(_check_scene_nodes(p, ["BackButton"]))
	return f


static func _check_scene_nodes(path: String, required: Array) -> Array[String]:
	var f: Array[String] = []
	var packed: PackedScene = load(path)
	if packed == null:
		f.append("场景无法加载: %s" % path)
		return f
	var inst := packed.instantiate()
	for node_name in required:
		if inst.find_child(node_name, true) == null:
			f.append("场景 %s 缺节点 %s" % [path, node_name])
	inst.free()
	return f
