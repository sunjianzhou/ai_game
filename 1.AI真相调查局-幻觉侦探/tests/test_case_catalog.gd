# 案件目录 + 解锁 + 新增案件只加数据（无需改代码）
static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	# 真实 catalog 含 case_001（autoload 经 tree 取）
	var loader = _tree.root.get_node("ContentLoader")
	var cat: CaseCatalog = loader.get_catalog()
	var has_case := false
	for c in cat.cases:
		if str(c.get("case_id", "")) == "case_001":
			has_case = true
	if not has_case:
		f.append("catalog 应含 case_001")
	# 解锁逻辑
	var cat2 := CaseCatalog.new()
	cat2.cases = [
		{"case_id": "case_001", "order": 1, "unlock_condition": "always"},
		{"case_id": "case_002", "order": 2, "unlock_condition": "prev_case_completed"},
	]
	if not cat2.is_unlocked("case_001", []):
		f.append("case_001(always) 应解锁")
	if cat2.is_unlocked("case_002", []):
		f.append("case_002(prev) 未完成前一案不应解锁")
	if not cat2.is_unlocked("case_002", ["case_001"]):
		f.append("case_002(prev) 完成前一案应解锁")
	if cat2.is_unlocked("nope", ["case_001"]):
		f.append("未知案件不应解锁")
	# 新增 case_999 只加数据：一个最小合法案件能被 parse（无需改核心代码）
	var case999 := {
		"schema_version": 2, "case_id": "case_999", "title": "测试案", "difficulty": "easy", "order": 999,
		"as_of": "2026-11-16", "briefing": "x", "objectives": ["x"], "fiction_note": "虚构",
		"report": {"segments": [
			{"type": "claim", "claim_id": "c1"},
			{"type": "claim", "claim_id": "c2"},
			{"type": "claim", "claim_id": "c3"},
		]},
		"claims": [
			{"claim_id": "c1", "text": "a", "claim_kind": "fact", "correct_label": "supported", "explanation": "x", "key_evidence_ids": ["e1"], "related_evidence_ids": ["e1"]},
			{"claim_id": "c2", "text": "b", "claim_kind": "fact", "correct_label": "contradicted", "explanation": "x", "key_evidence_ids": ["e2"], "related_evidence_ids": ["e2"]},
			{"claim_id": "c3", "text": "c", "claim_kind": "fact", "correct_label": "unverified", "explanation": "x", "key_evidence_ids": ["e3"], "related_evidence_ids": ["e3"]},
		],
		"evidence": [
			{"evidence_id": "e1", "title": "x", "source_type": "primary_record", "record_type": "log", "created_at": "2026-11-16", "reliability": "high", "reliability_basis": "x", "is_primary": true, "content_format": "text", "content": "x", "relations": []},
			{"evidence_id": "e2", "title": "x", "source_type": "primary_record", "record_type": "registry", "created_at": "2026-11-16", "reliability": "high", "reliability_basis": "x", "is_primary": true, "content_format": "text", "content": "x", "relations": []},
			{"evidence_id": "e3", "title": "x", "source_type": "internal_note", "record_type": "note", "created_at": "2026-11-16", "reliability": "medium", "reliability_basis": "x", "is_primary": false, "content_format": "text", "content": "x", "relations": []},
		],
		"final_decisions": {"preferred_action": "hold", "accepted_actions": [{"action": "hold", "score_weight": 1.0}]},
		"hints": [], "scoring": {}, "debrief": {"knowledge_card_id": "", "knowledge_title": "x", "knowledge_body": "x", "model_behavior_note": "x"},
	}
	var r := CaseLoader.parse_case(JSON.stringify(case999))
	if not r.ok:
		f.append("case_999 最小案件应可解析: %s" % str(r.errors))
	return f
