# 测试夹具（非测试文件，无 run()）：合成 3-claim case，结构同 case_001
static func make_case() -> CaseDefinition:
	var cd := CaseDefinition.new()
	var c1 := ClaimDefinition.new()
	c1.claim_id = "claim_001"
	c1.correct_label = "unverified"
	c1.key_evidence_ids = ["evidence_001", "evidence_004", "evidence_005"]
	c1.related_evidence_ids = ["evidence_001", "evidence_002", "evidence_004", "evidence_005"]
	cd.claims.append(c1)
	var c2 := ClaimDefinition.new()
	c2.claim_id = "claim_002"
	c2.correct_label = "contradicted"
	c2.key_evidence_ids = ["evidence_003"]
	c2.related_evidence_ids = ["evidence_003"]
	cd.claims.append(c2)
	var c3 := ClaimDefinition.new()
	c3.claim_id = "claim_003"
	c3.correct_label = "supported"
	c3.key_evidence_ids = ["evidence_002"]
	c3.related_evidence_ids = ["evidence_002"]
	cd.claims.append(c3)
	for i in range(1, 6):
		var e := EvidenceDefinition.new()
		e.evidence_id = "evidence_00%d" % i
		cd.evidence.append(e)
	cd.final_decisions = {
		"preferred_action": "revise",
		"accepted_actions": [
			{"action": "revise", "score_weight": 1.0},
			{"action": "hold", "score_weight": 0.6},
			{"action": "approve_with_caveat", "score_weight": 0.1},
			{"action": "approve", "score_weight": 0.0},
		],
	}
	cd.scoring = {"evidence": {"unrelated_penalty": 1.0, "miss_penalty": 1.0}}
	cd.hints = [{"hint_id": "hint_001", "type": "direction", "text": "x"}]
	cd.build_indexes()
	return cd


static func full_links() -> Dictionary:
	return {
		"claim_001": ["evidence_001", "evidence_004", "evidence_005"],
		"claim_002": ["evidence_003"],
		"claim_003": ["evidence_002"],
	}


static func make_session(labels: Array, linked: Dictionary, action: String = "revise", hint: String = "") -> CaseSession:
	var s := CaseSession.new(make_case())
	s.begin_briefing()
	s.begin_investigation()
	for i in range(labels.size()):
		s.judge_claim("claim_00%d" % (i + 1), labels[i])
	for claim_id in linked:
		for eid in linked[claim_id]:
			s.link_evidence(claim_id, eid)
	if hint != "":
		s.use_hint(hint)
	s.submit_final(action)
	return s
