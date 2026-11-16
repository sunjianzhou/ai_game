# 领域枚举 + 目录 + 定义类型测试
static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	_check_enums(f)
	_check_catalogs(f)
	_check_definitions(f)
	return f


static func _eq(f: Array, label: String, got, expected) -> void:
	if got != expected:
		f.append("%s = %s，应 %s" % [label, str(got), str(expected)])


static func _check_enums(f: Array) -> void:
	_eq(f, "cl_v supported", Enums.claim_label_value("supported"), Enums.ClaimLabel.supported)
	_eq(f, "cl_v contradicted", Enums.claim_label_value("contradicted"), Enums.ClaimLabel.contradicted)
	_eq(f, "cl_v unverified", Enums.claim_label_value("unverified"), Enums.ClaimLabel.unverified)
	_eq(f, "cl_v outdated", Enums.claim_label_value("outdated"), Enums.ClaimLabel.outdated)
	_eq(f, "cl_n supported", Enums.claim_label_name(Enums.ClaimLabel.supported), "supported")
	_eq(f, "cl_v bad", Enums.claim_label_value("bad"), -1)
	_eq(f, "fa_v approve", Enums.final_action_value("approve"), Enums.FinalAction.approve)
	_eq(f, "fa_v hold", Enums.final_action_value("hold"), Enums.FinalAction.hold)
	_eq(f, "fa_v revise", Enums.final_action_value("revise"), Enums.FinalAction.revise)
	_eq(f, "fa_n approve", Enums.final_action_name(Enums.FinalAction.approve), "approve")
	_eq(f, "fa_v bad", Enums.final_action_value("bad"), -1)
	_eq(f, "ck fact", Enums.claim_kind_value("fact"), Enums.ClaimKind.fact)
	_eq(f, "ck bad", Enums.claim_kind_value("bad"), -1)
	_eq(f, "rp corr", Enums.reasoning_pattern_value("correlation"), Enums.ReasoningPattern.correlation)
	_eq(f, "rp bad", Enums.reasoning_pattern_value("bad"), -1)
	_eq(f, "st primary", Enums.source_type_value("primary_record"), Enums.SourceType.primary_record)
	_eq(f, "st bad", Enums.source_type_value("bad"), -1)
	_eq(f, "rel high", Enums.reliability_value("high"), Enums.Reliability.high)
	_eq(f, "rel bad", Enums.reliability_value("bad"), -1)
	_eq(f, "dif easy", Enums.difficulty_value("easy"), Enums.Difficulty.easy)
	_eq(f, "dif bad", Enums.difficulty_value("bad"), -1)
	_eq(f, "ht direction", Enums.hint_type_value("direction"), Enums.HintType.direction)
	_eq(f, "ht bad", Enums.hint_type_value("bad"), -1)
	_eq(f, "cf text", Enums.content_format_value("text"), Enums.ContentFormat.text)
	_eq(f, "cf bad", Enums.content_format_value("bad"), -1)
	_eq(f, "rt snapshot", Enums.record_type_value("snapshot"), Enums.RecordType.snapshot)
	_eq(f, "rt bad", Enums.record_type_value("bad"), -1)
	_eq(f, "rel supports", Enums.relation_value("supports"), Enums.Relation.supports)
	_eq(f, "rel bad", Enums.relation_value("bad"), -1)
	_eq(f, "uc always", Enums.unlock_condition_value("always"), Enums.UnlockCondition.always)
	_eq(f, "uc bad", Enums.unlock_condition_value("bad"), -1)


static func _check_catalogs(f: Array) -> void:
	_eq(f, "labels size", ClaimLabelCatalog.LABELS.size(), 4)
	for key in ["supported", "contradicted", "unverified", "outdated"]:
		var e: Dictionary = ClaimLabelCatalog.LABELS.get(key, {})
		if e.get("display_name", "") == "" or e.get("definition", "") == "" or e.get("example", "") == "":
			f.append("ClaimLabelCatalog[%s] 缺字段" % key)
	_eq(f, "actions size", FinalActionCatalog.ACTIONS.size(), 4)


static func _check_definitions(f: Array) -> void:
	var cd := CaseDefinition.new()
	cd.claims.append(ClaimDefinition.new())
	cd.evidence.append(EvidenceDefinition.new())
	cd.claims[0].claim_id = "c1"
	cd.evidence[0].evidence_id = "e1"
	cd.build_indexes()
	if cd.claims_by_id.get("c1") == null or cd.evidence_by_id.get("e1") == null:
		f.append("build_indexes 未建索引")
