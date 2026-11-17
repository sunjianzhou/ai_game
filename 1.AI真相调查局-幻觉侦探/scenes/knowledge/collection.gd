extends Control


func _ready() -> void:
	$Margin/VBox/BackButton.pressed.connect(_on_back)
	_render()


func _render() -> void:
	var loader = get_node("/root/ContentLoader")
	var cards = loader.get_knowledge_cards()
	var progress = GameFlow.player_progress
	var titles = loader.get_titles()
	$Margin/VBox/CountLabel.text = "知识卡 %d/%d · 称号 %d/%d" % [progress.collected_cards.size(), cards.size(), progress.earned_titles.size(), titles.size()]
	var box: VBoxContainer = $Margin/VBox/Scroll/Cards
	for child in box.get_children():
		child.queue_free()
	for card in cards:
		var panel := PanelContainer.new()
		var vb := VBoxContainer.new()
		var lbl := Label.new()
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if progress.collected_cards.has(card.card_id):
			lbl.text = "■ %s\n%s\n适用范围：%s\n依据：%s" % [card.title, card.body, card.scope, str(card.references)]
		else:
			lbl.text = "□ 未解锁（完成对应案件后解锁）"
		vb.add_child(lbl)
		panel.add_child(vb)
		box.add_child(panel)
	for tid in progress.earned_titles:
		for t in titles:
			if str(t.get("title_id", "")) == tid:
				var lbl := Label.new()
				lbl.text = "★ %s —— %s" % [str(t.get("name", tid)), str(t.get("description", ""))]
				box.add_child(lbl)


func _on_back() -> void:
	GameFlow.goto(GameFlow.Page.MAIN_MENU)
