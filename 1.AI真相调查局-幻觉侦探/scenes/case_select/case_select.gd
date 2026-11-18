extends Control


func _ready() -> void:
	$Center/VBoxContainer/BackButton.pressed.connect(_on_back)
	_render()


func _render() -> void:
	var loader = get_node("/root/ContentLoader")
	var cat: CaseCatalog = loader.get_catalog()
	var list: VBoxContainer = $Center/VBoxContainer/CaseList
	for child in list.get_children():
		child.queue_free()
	var cases: Array = cat.cases.duplicate()
	cases.sort_custom(func(a, b): return int(a.get("order", 0)) < int(b.get("order", 0)))
	var completed: Array = []
	var progress = GameFlow.player_progress
	for cid in progress.progress:
		if bool(progress.progress[cid].get("completed", false)):
			completed.append(cid)
	for c in cases:
		var cid := str(c.get("case_id", ""))
		var btn := Button.new()
		var unlocked: bool = cat.is_unlocked(cid, completed)
		var best := int(progress.progress.get(cid, {}).get("best_score", -1))
		if unlocked:
			btn.text = "%s · %s%s" % [str(c.get("title", "")), str(c.get("summary", "")), " · 最高分 %d" % best if best >= 0 else ""]
			btn.pressed.connect(_on_case.bind(cid))
		else:
			btn.text = "%s（完成前一案解锁）" % str(c.get("title", ""))
			btn.disabled = true
		list.add_child(btn)


func _on_case(case_id: String) -> void:
	if GameFlow.start_case(case_id):
		GameFlow.goto(GameFlow.Page.BRIEFING)


func _on_back() -> void:
	GameFlow.goto(GameFlow.Page.MAIN_MENU)
