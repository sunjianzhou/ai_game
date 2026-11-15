class_name PlayerProgress
extends RefCounted
# 存档 DTO（S1 最小壳；字段带类型注解，S2 只加字段不改签名）

var save_version: int = 2
var settings: Dictionary = {
	"volume_master": 0.8,
	"volume_music": 0.6,
	"font_scale": 1.0,
	"window_mode": "windowed",
}
var progress: Dictionary = {}          # case_id -> { completed, best_score }
var collected_cards: Array = []
var earned_titles: Array = []
var last_case_id: String = ""


func to_dict() -> Dictionary:
	return {
		"save_version": save_version,
		"settings": settings.duplicate(),
		"progress": progress.duplicate(true),
		"collected_cards": collected_cards.duplicate(),
		"earned_titles": earned_titles.duplicate(),
		"last_case_id": last_case_id,
	}


static func from_dict(d: Dictionary) -> PlayerProgress:
	var p := PlayerProgress.new()
	p.save_version = int(d.get("save_version", 2))
	p.settings = (d.get("settings", {}) as Dictionary).duplicate()
	p.progress = (d.get("progress", {}) as Dictionary).duplicate(true)
	p.collected_cards = (d.get("collected_cards", []) as Array).duplicate()
	p.earned_titles = (d.get("earned_titles", []) as Array).duplicate()
	p.last_case_id = str(d.get("last_case_id", ""))
	return p
