class_name ClaimDefinition
extends RefCounted

var claim_id: String = ""
var text: String = ""
var claim_kind: String = "fact"        # fact/calculation/inference
var reasoning_pattern: Variant = null  # correlation/causation/subset_vs_total/other 或 null
var correct_label: String = ""
var explanation: String = ""
var key_evidence_ids: Array[String] = []      # 判定时必须考虑的证据（不区分支持/反对）
var related_evidence_ids: Array[String] = []  # 相关可关联（含 key）
