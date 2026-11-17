# 离线静态扫描：核心脚本不得引用网络/外部进程 API
static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	var forbidden := ["HTTPRequest", "WebSocketPeer", "HTTPClient", "OS.shell_open"]
	for d in ["res://scripts", "res://scenes"]:
		_scan(d, forbidden, f)
	return f


static func _scan(dir: String, forbidden: Array, f: Array) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	d.list_dir_begin()
	var name := d.get_next()
	while name != "":
		if d.current_is_dir():
			if name != "." and name != "..":
				_scan(dir.path_join(name), forbidden, f)
		elif name.ends_with(".gd"):
			var txt := FileAccess.get_file_as_string(dir.path_join(name))
			for b in forbidden:
				if txt.contains(b):
					f.append("离线违规：%s 含 %s" % [dir.path_join(name), b])
		name = d.get_next()
	d.list_dir_end()
