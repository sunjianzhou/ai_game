extends Control


func _ready() -> void:
	$VBoxContainer/CaseCard.pressed.connect(_on_case_card)


func _on_case_card() -> void:
	if GameFlow.start_case("case_001"):
		GameFlow.goto(GameFlow.Page.BRIEFING)
