extends Control


func _ready() -> void:
	$VBoxContainer/ReviseButton.pressed.connect(_on_submit.bind("revise"))
	$VBoxContainer/HoldButton.pressed.connect(_on_submit.bind("hold"))
	$VBoxContainer/CaveatButton.pressed.connect(_on_submit.bind("approve_with_caveat"))
	$VBoxContainer/ApproveButton.pressed.connect(_on_submit.bind("approve"))


func _on_submit(action: String) -> void:
	if GameFlow.submit_final(action):
		GameFlow.goto(GameFlow.Page.RESULTS)
