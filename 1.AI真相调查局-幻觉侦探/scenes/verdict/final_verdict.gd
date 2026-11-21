extends Control


func _ready() -> void:
	BackgroundUtil.add_animated_background(self)
	$Center/VBoxContainer/ReviseButton.pressed.connect(_on_submit.bind("revise"))
	$Center/VBoxContainer/HoldButton.pressed.connect(_on_submit.bind("hold"))
	$Center/VBoxContainer/CaveatButton.pressed.connect(_on_submit.bind("approve_with_caveat"))
	$Center/VBoxContainer/ApproveButton.pressed.connect(_on_submit.bind("approve"))
	$Center/VBoxContainer/BackButton.pressed.connect(_on_back)
	$Center/VBoxContainer/TitleLabel.text = "这份报告应该如何处理？（提交后进入评分，不能反悔）"
	var a := FinalActionCatalog.ACTIONS
	$Center/VBoxContainer/ReviseButton.text = "退回修订 —— %s" % a["revise"]["description"]
	$Center/VBoxContainer/HoldButton.text = "暂缓发布 —— %s" % a["hold"]["description"]
	$Center/VBoxContainer/CaveatButton.text = "附带限定发布 —— %s" % a["approve_with_caveat"]["description"]
	$Center/VBoxContainer/ApproveButton.text = "批准发布 —— %s" % a["approve"]["description"]
	$Center/VBoxContainer/BackButton.text = "返回调查（不提交，继续修改）"


func _on_submit(action: String) -> void:
	if GameFlow.submit_final(action):
		GameFlow.goto(GameFlow.Page.RESULTS)
	else:
		$Center/VBoxContainer/StatusLabel.text = "提交失败：可能尚未判定完所有陈述"


func _on_back() -> void:
	GameFlow.goto(GameFlow.Page.INVESTIGATION)
