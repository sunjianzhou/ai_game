extends Control


func _ready() -> void:
	$VBoxContainer/StartButton.pressed.connect(_on_start)
	var def = GameFlow.current_case_def
	if def != null:
		$VBoxContainer/TitleLabel.text = def.title
		$VBoxContainer/BriefingLabel.text = def.briefing
		$VBoxContainer/AsOfLabel.text = "调查基准时间：" + def.as_of
		$VBoxContainer/ObjectivesLabel.text = "目标：" + "\n".join(def.objectives)
		$VBoxContainer/FictionLabel.text = def.fiction_note


func _on_start() -> void:
	if GameFlow.begin_investigation():
		GameFlow.goto(GameFlow.Page.INVESTIGATION)
