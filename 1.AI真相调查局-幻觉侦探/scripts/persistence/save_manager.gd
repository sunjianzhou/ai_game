extends Node
# 存档/设置/草稿唯一写者（完整契约）

signal setting_changed(key, value)

const SAVE_VERSION := 2

var base_path: String = "user://"
var read_only: bool = false
var _progress: PlayerProgress = PlayerProgress.new()
var _loaded: bool = false


func ensure_loaded() -> SaveLoadResult:
	if _loaded:
		return SaveLoadResult.ok(_progress)
	_loaded = true
	var path := _p("save.json")
	if not FileAccess.file_exists(path):
		return SaveLoadResult.missing(_progress)
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null or not (parsed is Dictionary):
		_backup_corrupt()
		return SaveLoadResult.corrupt(_progress, "JSON 解析失败")
	var ver := int(parsed.get("save_version", -1))
	if ver < 0:
		_backup_corrupt()
		return SaveLoadResult.corrupt(_progress, "缺 save_version")
	if ver > SAVE_VERSION:
		read_only = true
		return SaveLoadResult.future_version(_progress, ver)
	_progress = PlayerProgress.from_dict(parsed)
	return SaveLoadResult.ok(_progress)


func save(progress: PlayerProgress) -> bool:
	if read_only:
		return false
	progress.settings = _progress.settings.duplicate()
	progress.save_version = SAVE_VERSION
	_progress = progress
	return _atomic_write(progress)


func get_setting(key: String) -> Variant:
	return _progress.settings.get(key)


func set_setting(key: String, value: Variant) -> void:
	if not _progress.settings.has(key):
		return
	_progress.settings[key] = value
	setting_changed.emit(key, value)


func save_draft(dict: Dictionary) -> bool:
	if read_only:
		return false
	var tmp := _p("draft.tmp")
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(dict))
	f.flush()
	f.close()
	if f.get_error() != OK:
		return false
	DirAccess.rename_absolute(tmp, _p("draft.json"))
	return true


func load_draft() -> Dictionary:
	var path := _p("draft.json")
	if not FileAccess.file_exists(path):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null or not (parsed is Dictionary):
		return {}
	return parsed


func clear_draft() -> void:
	var dir := DirAccess.open(base_path)
	if dir != null and dir.file_exists("draft.json"):
		dir.remove("draft.json")


func _p(name: String) -> String:
	return base_path.path_join(name)


func _backup_corrupt() -> void:
	var dir := DirAccess.open(base_path)
	if dir != null and dir.file_exists("save.json"):
		DirAccess.rename_absolute(_p("save.json"), _p("save.corrupt.%d" % Time.get_unix_time_from_system()))


func _atomic_write(progress: PlayerProgress) -> bool:
	DirAccess.make_dir_recursive_absolute(base_path)
	var dir := DirAccess.open(base_path)
	if dir == null:
		return false
	var json_path := _p("save.json")
	var tmp_path := _p("save.tmp")
	var bak_path := _p("save.bak")
	var f := FileAccess.open(tmp_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(progress.to_dict()))
	f.flush()
	f.close()
	if f.get_error() != OK:
		return false
	if dir.file_exists("save.bak"):
		dir.remove("save.bak")
	if dir.file_exists("save.json"):
		DirAccess.rename_absolute(json_path, bak_path)
	if DirAccess.rename_absolute(tmp_path, json_path) != OK:
		if dir.file_exists("save.bak"):
			DirAccess.rename_absolute(bak_path, json_path)
		return false
	return true
