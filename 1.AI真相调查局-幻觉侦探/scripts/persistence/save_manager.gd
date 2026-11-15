extends Node
# 存档/设置唯一写者。S1 只持内存默认值 + 信号；真实原子写/迁移在 S2（接口不变）。

signal setting_changed(key, value)

var base_path: String = "user://"     # 路径注入点（测试传临时目录）

var _settings: Dictionary = {
	"volume_master": 0.8,
	"volume_music": 0.6,
	"font_scale": 1.0,
	"window_mode": "windowed",
}


func load() -> PlayerProgress:
	return PlayerProgress.new()          # S1 不读盘


func save(_progress: PlayerProgress) -> bool:
	return true                          # S1 不落盘；S2 实现原子写 + 迁移


func get_setting(key: String) -> Variant:
	return _settings.get(key)            # 未知键返回 null


func set_setting(key: String, value: Variant) -> void:
	if not _settings.has(key):
		return
	_settings[key] = value
	setting_changed.emit(key, value)
