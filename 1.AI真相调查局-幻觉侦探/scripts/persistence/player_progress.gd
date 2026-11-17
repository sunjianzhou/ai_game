class_name PlayerProgress
extends RefCounted
# 存档 DTO

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
	p.settings = _dict(d.get("settings"))
	p.progress = _dict(d.get("progress"))
	p.collected_cards = _strs(d.get("collected_cards"))
	p.earned_titles = _strs(d.get("earned_titles"))
	p.last_case_id = str(d.get("last_case_id", ""))
	return p


static func _dict(v) -> Dictionary:
	return v.duplicate(true) if v is Dictionary else {}


static func _strs(v) -> Array:
	var out: Array = []
	if v is Array:
		for x in v:
			if x is String:
				out.append(x)
	return out
