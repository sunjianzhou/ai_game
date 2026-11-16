extends Control

var _active_claim: String = ""

@onready var report: RichTextLabel = $ReportRichText
@onready var pips: HBoxContainer = $ClaimPips
@onready var evidence_list: VBoxContainer = $EvidenceList


func _ready() -> void:
	$JudgementBar/JudgeSupported.pressed.connect(_on_judge.bind("supported"))
	$JudgementBar/JudgeContradicted.pressed.connect(_on_judge.bind("contradicted"))
	$JudgementBar/JudgeUnverified.pressed.connect(_on_judge.bind("unverified"))
	$JudgementBar/JudgeOutdated.pressed.connect(_on_judge.bind("outdated"))
	$JudgementBar/HintButton.pressed.connect(_on_hint)
	$JudgementBar/SubmitButton.pressed.connect(_on_submit)
	report.meta_clicked.connect(_on_meta_clicked)
	_render()


func _render() -> void:
	var def = GameFlow.current_case_def
	if def == null:
		return
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
		dot.text = "●" if GameFlow.current_session.is_judged(c.claim_id) else "○"
		pips.add_child(dot)
	for e in def.evidence:
		var btn := Button.new()
		btn.text = "%s（%s）" % [e.title, e.source_type]
		btn.pressed.connect(_on_evidence.bind(e.evidence_id))
		evidence_list.add_child(btn)


func _on_meta_clicked(meta) -> void:
	_active_claim = str(meta)


func _on_judge(label: String) -> void:
	if _active_claim == "":
		return
	GameFlow.judge_claim(_active_claim, label)


func _on_evidence(evidence_id: String) -> void:
	var viewer = preload("res://scenes/investigation/evidence_viewer.tscn").instantiate()
	viewer.setup(evidence_id, _active_claim)
	add_child(viewer)


func _on_hint() -> void:
	var def = GameFlow.current_case_def
	if def == null or def.hints.is_empty():
		return
	GameFlow.use_hint(str(def.hints[0].get("hint_id", "")))


func _on_submit() -> void:
	GameFlow.goto(GameFlow.Page.FINAL_VERDICT)
