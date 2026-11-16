extends Control


func _ready() -> void:
	var def = GameFlow.current_case_def
	if def != null:
		$VBoxContainer/TitleLabel.text = str(def.debrief.get("knowledge_title", ""))
		$VBoxContainer/BodyLabel.text = str(def.debrief.get("knowledge_body", ""))
	$VBoxContainer/BackButton.pressed.connect(_on_back)


func _on_back() -> void:
	GameFlow.end_case()
	GameFlow.goto(GameFlow.Page.CASE_SELECT)
