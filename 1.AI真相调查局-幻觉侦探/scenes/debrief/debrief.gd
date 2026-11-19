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
			bb += "[%s · +%d/%d 分] %s\n" % ["对" if cr.matched else "错", int(cr.points), int(cr.max_points), cd.text]
			bb += "  你判：%s · 正确：%s\n" % [cr.player_label, cr.correct_label]
			bb += "  解释：%s\n\n" % cd.explanation
	# 丢分说明
	if result != null and result.total < 100:
		bb += "━━ 你丢的 %d 分 ━━\n" % (100 - result.total)
		var b: Dictionary = result.breakdown
		if float(b.get("final_action", 0.0)) < 10.0:
			var chosen := str(result.final_action_detail.get("action", ""))
			var chosen_name := str(FinalActionCatalog.ACTIONS.get(chosen, {}).get("display_name", chosen))
			var preferred_name := str(FinalActionCatalog.ACTIONS.get(str(def.final_decisions.get("preferred_action", "")), {}).get("display_name", "—"))
			bb += "· 最终动作：你选了「%s」，正确是「%s」\n" % [chosen_name, preferred_name]
		if result.hint_used:
			bb += "· 使用了提示（-5 分）\n"
		bb += "\n"
	# 大模型讲解（与本案判定区分）
	if def != null:
		bb += "━━ 关于大模型的说明（与本案判定无关）━━\n"
		bb += str(def.debrief.get("model_behavior_note", ""))
		bb += "\n\n"
		bb += str(def.debrief.get("knowledge_body", ""))
	$Margin/VBoxContainer/Scroll/BodyLabel.text = bb
	$Margin/VBoxContainer/BackButton.pressed.connect(_on_back)


func _on_back() -> void:
	GameFlow.end_case()
	GameFlow.goto(GameFlow.Page.CASE_SELECT)
