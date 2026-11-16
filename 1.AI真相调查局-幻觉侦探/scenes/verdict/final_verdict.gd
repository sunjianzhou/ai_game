extends Control


func _ready() -> void:
	$VBoxContainer/ReviseButton.pressed.connect(_on_submit.bind("revise"))
	$VBoxContainer/HoldButton.pressed.connect(_on_submit.bind("hold"))
	$VBoxContainer/CaveatButton.pressed.connect(_on_submit.bind("approve_with_caveat"))
	$VBoxContainer/ApproveButton.pressed.connect(_on_submit.bind("approve"))
	$VBoxContainer/BackButton.pressed.connect(_on_back)


func _on_submit(action: String) -> void:
	if GameFlow.submit_final(action):
		GameFlow.goto(GameFlow.Page.RESULTS)
	else:
		$VBoxContainer/StatusLabel.text = "提交失败：可能尚未判定完所有陈述"


func _on_back() -> void:
	GameFlow.goto(GameFlow.Page.INVESTIGATION)
