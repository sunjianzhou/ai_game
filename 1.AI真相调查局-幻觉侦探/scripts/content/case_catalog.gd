class_name CaseCatalog
extends RefCounted
# 案件清单（来自 content/cases/index.json）

var cases: Array = []   # [{case_id,title,difficulty,order,unlock_condition,summary}]


func is_unlocked(case_id: String, completed_ids: Array) -> bool:
	var target := _find(case_id)
	if target.is_empty():
		return false
	var cond := str(target.get("unlock_condition", "always"))
	if cond == "always":
		return true
	if cond == "prev_case_completed":
		var order := int(target.get("order", 0))
		for c in cases:
			if int(c.get("order", 0)) == order - 1:
				return completed_ids.has(str(c.get("case_id", "")))
		return false
	return false


func _find(case_id: String) -> Dictionary:
	for c in cases:
		if str(c.get("case_id", "")) == case_id:
			return c
	return {}
