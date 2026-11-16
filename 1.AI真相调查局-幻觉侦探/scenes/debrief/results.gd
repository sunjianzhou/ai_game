extends Control


func _ready() -> void:
	var r = GameFlow.current_result
	if r != null:
		var b: Dictionary = r.breakdown
		$Center/VBoxContainer/TotalLabel.text = "总分：%d" % r.total
		$Center/VBoxContainer/BreakdownLabel.text = "判定 %d + 证据 %d + 动作 %d" % [int(b.get("accuracy", 0.0)), int(b.get("evidence", 0.0)), int(b.get("final_action", 0.0))]
		$Center/VBoxContainer/HintPenaltyLabel.text = "提示扣分：%d" % int(r.hint_penalty)
		$Center/VBoxContainer/FinalActionLabel.text = "最终动作：%s" % str(r.final_action_detail.get("action", ""))
	$Center/VBoxContainer/DebriefButton.pressed.connect(_on_debrief)


func _on_debrief() -> void:
	if GameFlow.begin_debrief():
		GameFlow.goto(GameFlow.Page.DEBRIEF)
