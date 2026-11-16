extends CanvasLayer
# 证据查看器叠加层

signal evidence_link_requested(evidence_id: String)

var _evidence_id: String = ""
var _claim_id: String = ""


func setup(evidence_id: String, claim_id: String) -> void:
	_evidence_id = evidence_id
	_claim_id = claim_id
	var def = GameFlow.current_case_def
	if def != null:
		var e = def.evidence_by_id.get(evidence_id)
		if e != null:
			$Panel/VBoxContainer/TitleLabel.text = "%s（%s）" % [e.title, e.source_type]
			$Panel/VBoxContainer/InfoLabel.text = "记录：%s · 有效：%s ~ %s · 可靠度：%s · %s" % [e.created_at, str(e.valid_from), str(e.valid_until), e.reliability, "一手" if e.is_primary else "二手"]
			$Panel/VBoxContainer/ContentLabel.text = e.content
			$Panel/VBoxContainer/BasisLabel.text = "可靠度依据：" + e.reliability_basis
	if _claim_id == "":
		$Panel/VBoxContainer/Buttons/LinkButton.disabled = true
		$Panel/VBoxContainer/Buttons/LinkButton.text = "先点击报告中的陈述再关联"


func _ready() -> void:
	$Panel/VBoxContainer/Buttons/LinkButton.pressed.connect(_on_link)
	$Panel/VBoxContainer/Buttons/CloseButton.pressed.connect(_on_close)


func _on_link() -> void:
	if _evidence_id != "" and _claim_id != "":
		evidence_link_requested.emit(_evidence_id)
	queue_free()


func _on_close() -> void:
	queue_free()
