extends CanvasLayer
# 证据查看器叠加层

signal evidence_link_requested(evidence_id: String)

var _evidence_id: String = ""


func setup(evidence_id: String, _claim_id: String) -> void:
	_evidence_id = evidence_id
	var def = GameFlow.current_case_def
	if def != null:
		var e = def.evidence_by_id.get(evidence_id)
		if e != null:
			$Panel/TitleLabel.text = "%s（%s）" % [e.title, e.source_type]
			$Panel/InfoLabel.text = "记录：%s · 有效：%s ~ %s · 可靠度：%s · %s" % [e.created_at, str(e.valid_from), str(e.valid_until), e.reliability, "一手" if e.is_primary else "二手"]
			$Panel/ContentLabel.text = e.content
			$Panel/BasisLabel.text = "可靠度依据：" + e.reliability_basis


func _ready() -> void:
	$Panel/LinkButton.pressed.connect(_on_link)


func _on_link() -> void:
	if _evidence_id != "":
		evidence_link_requested.emit(_evidence_id)
	queue_free()
