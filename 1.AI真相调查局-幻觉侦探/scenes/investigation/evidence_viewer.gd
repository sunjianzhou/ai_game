extends CanvasLayer
# 证据查看器叠加层

var _evidence_id: String = ""
var _claim_id: String = ""


func setup(evidence_id: String, claim_id: String) -> void:
	_evidence_id = evidence_id
	_claim_id = claim_id
	var def = GameFlow.current_case_def
	if def != null:
		var e = def.evidence_by_id.get(evidence_id)
		if e != null:
			$Panel/TitleLabel.text = e.title
			$Panel/ContentLabel.text = e.content
			$Panel/BasisLabel.text = "可靠度依据：" + e.reliability_basis


func _ready() -> void:
	$Panel/LinkButton.pressed.connect(_on_link)


func _on_link() -> void:
	if _claim_id != "" and _evidence_id != "":
		GameFlow.link_evidence(_claim_id, _evidence_id)
	queue_free()
