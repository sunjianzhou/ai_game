extends Control

var _active_claim: String = ""

@onready var report: RichTextLabel = $Margin/VBox/Main/Left/ReportRichText
@onready var pips: HBoxContainer = $Margin/VBox/Header/ClaimPips
@onready var evidence_list: VBoxContainer = $Margin/VBox/Main/Right/Scroll/EvidenceList
@onready var status_label: Label = $Margin/VBox/Main/Left/StatusLabel
@onready var hint_label: Label = $Margin/VBox/HintLabel
@onready var case_title: Label = $Margin/VBox/Header/CaseTitle


func _ready() -> void:
	$Margin/VBox/JudgementBar/JudgeSupported.pressed.connect(_on_judge.bind("supported"))
	$Margin/VBox/JudgementBar/JudgeContradicted.pressed.connect(_on_judge.bind("contradicted"))
	$Margin/VBox/JudgementBar/JudgeUnverified.pressed.connect(_on_judge.bind("unverified"))
	$Margin/VBox/JudgementBar/JudgeOutdated.pressed.connect(_on_judge.bind("outdated"))
	$Margin/VBox/JudgementBar/HintButton.pressed.connect(_on_hint)
	$Margin/VBox/JudgementBar/SubmitButton.pressed.connect(_on_submit)
	report.meta_clicked.connect(_on_meta_clicked)
	_render()
	_refresh()


func _render() -> void:
	var def = GameFlow.current_case_def
	if def == null:
		return
	case_title.text = def.title
	report.bbcode_enabled = true
	var bb := ""
	for seg in def.report_segments:
		if str(seg.get("type", "")) == "claim":
			var cid := str(seg.get("claim_id", ""))
			var c = def.claims_by_id.get(cid)
			bb += "[url=%s]%s[/url]\n" % [cid, c.text]
		else:
			bb += str(seg.get("text", "")) + "\n"
	report.text = bb
	for c in def.claims:
		var dot := Label.new()
		dot.name = "Pip_%s" % c.claim_id
		pips.add_child(dot)
	for e in def.evidence:
		var btn := Button.new()
		btn.text = "%s（%s）" % [e.title, e.source_type]
		btn.pressed.connect(_on_evidence.bind(e.evidence_id))
		evidence_list.add_child(btn)


func _refresh() -> void:
	var def = GameFlow.current_case_def
	if def == null or GameFlow.current_session == null:
		return
	for c in def.claims:
		var pip = pips.get_node_or_null("Pip_%s" % c.claim_id)
		if pip != null:
			pip.text = "●" if GameFlow.current_session.is_judged(c.claim_id) else "○"
	if _active_claim != "":
		var c = def.claims_by_id.get(_active_claim)
		if c != null:
			var label := GameFlow.current_session.get_judgement(_active_claim)
			status_label.text = "当前陈述：%s（已判：%s）" % [c.text, label if label != "" else "未判"]
		var linked := GameFlow.current_session.get_linked_evidence(_active_claim)
		if not linked.is_empty():
			status_label.text += " · 已关联 %d 条证据" % linked.size()
	else:
		status_label.text = "点击报告中的陈述以开始判定"


func _on_meta_clicked(meta) -> void:
	_active_claim = str(meta)
	_refresh()


func _on_judge(label: String) -> void:
	if _active_claim == "":
		status_label.text = "请先点击报告中的一条陈述"
		return
	if GameFlow.judge_claim(_active_claim, label):
		_refresh()


func _on_evidence(evidence_id: String) -> void:
	var viewer = preload("res://scenes/investigation/evidence_viewer.tscn").instantiate()
	viewer.setup(evidence_id, _active_claim)
	viewer.evidence_link_requested.connect(_on_evidence_linked)
	add_child(viewer)


func _on_evidence_linked(evidence_id: String) -> void:
	if _active_claim != "":
		GameFlow.link_evidence(_active_claim, evidence_id)
		_refresh()


func _on_hint() -> void:
	var def = GameFlow.current_case_def
	if def == null or def.hints.is_empty():
		return
	var h = def.hints[0]
	if GameFlow.use_hint(str(h.get("hint_id", ""))):
		hint_label.text = "提示：%s（-5 分）" % str(h.get("text", ""))


func _on_submit() -> void:
	if GameFlow.current_session != null and GameFlow.current_session.phase != CaseSession.Phase.READY_TO_SUBMIT:
		status_label.text = "仍有陈述未判定，无法提交"
		return
	GameFlow.goto(GameFlow.Page.FINAL_VERDICT)
