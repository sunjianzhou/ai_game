extends Control


func _ready() -> void:
	var def = GameFlow.current_case_def
	var result = GameFlow.current_result
	var bb := ""
	if def != null:
		bb += "知识点：%s\n\n" % str(def.debrief.get("knowledge_title", ""))
	if result != null and def != null:
		for cr in result.claims:
			var cd = def.claims_by_id.get(cr.claim_id)
			if cd == null:
				continue
			bb += "[%s] %s\n" % ["对" if cr.matched else "错", cd.text]
			bb += "  你判：%s · 正确：%s\n" % [cr.player_label, cr.correct_label]
			bb += "  解释：%s\n\n" % cd.explanation
	if def != null:
		bb += str(def.debrief.get("knowledge_body", ""))
	$VBoxContainer/BodyLabel.text = bb
	$VBoxContainer/BackButton.pressed.connect(_on_back)


func _on_back() -> void:
	GameFlow.end_case()
	GameFlow.goto(GameFlow.Page.CASE_SELECT)
