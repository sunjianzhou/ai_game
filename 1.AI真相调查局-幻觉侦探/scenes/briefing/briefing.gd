extends Control


func _ready() -> void:
	BackgroundUtil.add_animated_background(self)
	$Margin/VBoxContainer/StartButton.pressed.connect(_on_start)
	var def = GameFlow.current_case_def
	if def != null:
		$Margin/VBoxContainer/TitleLabel.text = def.title
		$Margin/VBoxContainer/BriefingLabel.text = def.briefing
		$Margin/VBoxContainer/AsOfLabel.text = "调查基准时间：" + def.as_of
		$Margin/VBoxContainer/ObjectivesLabel.text = "目标：" + "\n".join(def.objectives)
		$Margin/VBoxContainer/FictionLabel.text = def.fiction_note


func _on_start() -> void:
	if GameFlow.begin_investigation():
		GameFlow.goto(GameFlow.Page.INVESTIGATION)
