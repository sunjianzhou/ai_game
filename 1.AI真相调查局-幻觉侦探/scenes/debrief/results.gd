extends Control


func _ready() -> void:
	var r = GameFlow.current_result
	if r != null:
		var b: Dictionary = r.breakdown
		$Center/VBoxContainer/TotalLabel.text = "总分：%d / 100" % r.total
		$Center/VBoxContainer/BreakdownLabel.text = "判定 %d/60 · 证据 %d/30 · 动作 %d/10" % [int(b.get("accuracy", 0.0)), int(b.get("evidence", 0.0)), int(b.get("final_action", 0.0))]
		$Center/VBoxContainer/HintPenaltyLabel.text = "提示扣分：%d" % int(r.hint_penalty)
		var chosen := str(r.final_action_detail.get("action", ""))
		var chosen_name := str(FinalActionCatalog.ACTIONS.get(chosen, {}).get("display_name", chosen))
		var def = GameFlow.current_case_def
		if def != null:
			var preferred := str(def.final_decisions.get("preferred_action", ""))
			var preferred_name := str(FinalActionCatalog.ACTIONS.get(preferred, {}).get("display_name", preferred))
			var pts := int(float(r.final_action_detail.get("points", 0.0)))
			if chosen == preferred:
				$Center/VBoxContainer/FinalActionLabel.text = "最终动作：%s（正确，+%d 分）" % [chosen_name, pts]
			else:
				$Center/VBoxContainer/FinalActionLabel.text = "最终动作：%s（正确是「%s」，动作只得 %d/10 分）" % [chosen_name, preferred_name, pts]
		else:
			$Center/VBoxContainer/FinalActionLabel.text = "最终动作：%s" % chosen_name
	$Center/VBoxContainer/DebriefButton.pressed.connect(_on_debrief)


func _on_debrief() -> void:
	if GameFlow.begin_debrief():
		GameFlow.goto(GameFlow.Page.DEBRIEF)
