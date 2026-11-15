extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/CollectionButton.pressed.connect(_on_collection_pressed)
	$CenterContainer/VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	GameFlow.case_started.connect(_on_case_started)


func _exit_tree() -> void:
	if GameFlow.case_started.is_connected(_on_case_started):
		GameFlow.case_started.disconnect(_on_case_started)


func _on_start_pressed() -> void:
	GameFlow.goto(GameFlow.Page.CASE_SELECT)


func _on_collection_pressed() -> void:
	GameFlow.goto(GameFlow.Page.COLLECTION)


func _on_settings_pressed() -> void:
	GameFlow.goto(GameFlow.Page.SETTINGS)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_case_started(_id: String) -> void:
	pass
