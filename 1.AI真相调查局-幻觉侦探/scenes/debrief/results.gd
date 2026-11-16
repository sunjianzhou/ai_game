extends Control


func _ready() -> void:
	var r = GameFlow.current_result
	if r != null:
		$VBoxContainer/TotalLabel.text = "总分：%d" % r.total
		$VBoxContainer/HintPenaltyLabel.text = "提示扣分：%d" % int(r.hint_penalty)
		$VBoxContainer/FinalActionLabel.text = "最终动作：%s" % str(r.final_action_detail.get("action", ""))
	$VBoxContainer/DebriefButton.pressed.connect(_on_debrief)


func _on_debrief() -> void:
	if GameFlow.begin_debrief():
		GameFlow.goto(GameFlow.Page.DEBRIEF)
