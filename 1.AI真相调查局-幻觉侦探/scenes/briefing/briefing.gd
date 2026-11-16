extends Control


func _ready() -> void:
	$VBoxContainer/StartButton.pressed.connect(_on_start)
	var def = GameFlow.current_case_def
	if def != null:
		$VBoxContainer/TitleLabel.text = def.title
		$VBoxContainer/BriefingLabel.text = def.briefing
		$VBoxContainer/AsOfLabel.text = "调查基准时间：" + def.as_of


func _on_start() -> void:
	GameFlow.begin_investigation()
	GameFlow.goto(GameFlow.Page.INVESTIGATION)
