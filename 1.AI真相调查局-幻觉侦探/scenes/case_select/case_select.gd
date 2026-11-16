extends Control


func _ready() -> void:
	var loader = get_node("/root/ContentLoader")
	var cat = loader.get_catalog()
	if not cat.cases.is_empty():
		var c = cat.cases[0]
		$Center/VBoxContainer/CaseCard.text = "%s · %s" % [str(c.get("title", "")), str(c.get("summary", ""))]
		$Center/VBoxContainer/CaseCard.pressed.connect(_on_case.bind(str(c.get("case_id", ""))))
	$Center/VBoxContainer/BackButton.pressed.connect(_on_back)


func _on_case(case_id: String) -> void:
	if GameFlow.start_case(case_id):
		GameFlow.goto(GameFlow.Page.BRIEFING)


func _on_back() -> void:
	GameFlow.goto(GameFlow.Page.MAIN_MENU)
