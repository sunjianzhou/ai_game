# CaseSession 状态机 + 会话类型测试（会话级；GameFlow 层用例在 Task 6 加）
static func run(tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	_check_init(f)
	_check_judge(f)
	_check_link(f)
	_check_hint(f)
	_check_submit(f)
	_check_reset(f)
	_check_roundtrip(f)
	_check_gameflow(f, tree)
	return f


static func _check_gameflow(f: Array, tree: SceneTree) -> void:
	var gf = tree.root.get_node("GameFlow")
	if not gf.start_case("case_001"):
		f.append("start_case(case_001) 应成功")
		return
	if gf.current_session.phase != CaseSession.Phase.BRIEFING:
		f.append("start_case 后应 BRIEFING")
	if gf.start_case("nope"):
		f.append("start_case(不存在) 应失败")
	if not gf.begin_investigation():
		f.append("begin_investigation 应成功")
	for i in [1, 2, 3]:
		gf.judge_claim("claim_00%d" % i, "unverified")
	if gf.current_session.phase != CaseSession.Phase.READY_TO_SUBMIT:
		f.append("判 3 条后应 READY_TO_SUBMIT")
	if not gf.link_evidence("claim_001", "evidence_001"):
		f.append("READY 下 link 应 true")
	if not gf.judge_claim("claim_001", "contradicted"):
		f.append("READY 下 judge 应 true")
	if gf.current_session.phase != CaseSession.Phase.READY_TO_SUBMIT:
		f.append("READY 改判后应保持 READY")
	if not gf.submit_final("revise"):
		f.append("submit_final 应成功")
	if gf.current_result == null:
		f.append("submit 后 current_result 应非空")
	if not gf.submit_final("revise"):
		f.append("submit 同参幂等应 true")
	if gf.submit_final("hold"):
		f.append("submit 异参应 false")
	var bs := int(gf.player_progress.progress.get("case_001", {}).get("best_score", -1))
	if bs < 0:
		f.append("submit 后应更新 best_score")
	if not gf.begin_debrief():
		f.append("begin_debrief 应成功")
	if not gf.player_progress.collected_cards.has("card_fc_001"):
		f.append("debrief 后应收集 card_fc_001")
	var saved_bs := int(gf.player_progress.progress.get("case_001", {}).get("best_score", -1))
	gf.reset_case()
	if int(gf.player_progress.progress.get("case_001", {}).get("best_score", -1)) != saved_bs:
		f.append("reset_case 应保留 best_score")
	gf.end_case()
	if gf.current_session != null:
		f.append("end_case 应清 session")
	_check_guard(f, tree)


static func _check_guard(f: Array, tree: SceneTree) -> void:
	var gf = tree.root.get_node("GameFlow")
	if gf.can_goto(gf.Page.RESULTS):
		f.append("无 session 时 RESULTS 不可达")
	gf.start_case("case_001")
	if not gf.can_goto(gf.Page.BRIEFING):
		f.append("BRIEFING 应可去 briefing")
	if gf.can_goto(gf.Page.RESULTS):
		f.append("BRIEFING 不可去 results")
	gf.end_case()


static func _make_case(claim_count: int = 3) -> CaseDefinition:
	var cd := CaseDefinition.new()
	for i in range(1, claim_count + 1):
		var c := ClaimDefinition.new()
		c.claim_id = "claim_00%d" % i
		c.correct_label = "unverified"
		cd.claims.append(c)
	for i in [1, 2]:
		var e := EvidenceDefinition.new()
		e.evidence_id = "evidence_00%d" % i
		cd.evidence.append(e)
	cd.hints.append({"hint_id": "hint_001", "type": "direction", "text": "x"})
	cd.build_indexes()
	return cd


static func _eq(f: Array, label: String, got, expected) -> void:
	if got != expected:
		f.append("%s = %s，应 %s" % [label, str(got), str(expected)])


static func _check_init(f: Array) -> void:
	var s := CaseSession.new(_make_case())
	_eq(f, "init phase", s.phase, CaseSession.Phase.NOT_STARTED)
	_eq(f, "empty all_judged", CaseSession.new(_make_case(0)).all_claims_judged(), false)
	_eq(f, "begin_briefing", s.begin_briefing(), true)
	_eq(f, "briefing phase", s.phase, CaseSession.Phase.BRIEFING)
	_eq(f, "begin_investigation", s.begin_investigation(), true)
	_eq(f, "investigating phase", s.phase, CaseSession.Phase.INVESTIGATING)


static func _check_judge(f: Array) -> void:
	var s := CaseSession.new(_make_case())
	s.begin_briefing()
	s.begin_investigation()
	_eq(f, "judge unknown id", s.judge_claim("nope", "supported"), false)
	_eq(f, "judge bad label", s.judge_claim("claim_001", "bad"), false)
	_eq(f, "all_judged before", s.all_claims_judged(), false)
	for i in [1, 2, 3]:
		_eq(f, "judge claim_00%d" % i, s.judge_claim("claim_00%d" % i, "unverified"), true)
	_eq(f, "all_judged after", s.all_claims_judged(), true)
	_eq(f, "phase ready", s.phase, CaseSession.Phase.READY_TO_SUBMIT)
	# READY 下改判仍保持 READY
	_eq(f, "re-judge in ready", s.judge_claim("claim_001", "contradicted"), true)
	_eq(f, "still ready", s.phase, CaseSession.Phase.READY_TO_SUBMIT)
	_eq(f, "get_judgement", s.get_judgement("claim_001"), "contradicted")
	_eq(f, "get_judgement unjudged", s.get_judgement("nope"), "")


static func _check_link(f: Array) -> void:
	var s := CaseSession.new(_make_case())
	s.begin_briefing()
	s.begin_investigation()
	_eq(f, "link unknown claim", s.link_evidence("nope", "evidence_001"), false)
	_eq(f, "link unknown ev", s.link_evidence("claim_001", "nope"), false)
	_eq(f, "link ok", s.link_evidence("claim_001", "evidence_001"), true)
	_eq(f, "link any combo", s.link_evidence("claim_001", "evidence_002"), true)
	_eq(f, "link dedup", s.link_evidence("claim_001", "evidence_001"), true)
	_eq(f, "linked count", s.get_linked_evidence("claim_001").size(), 2)
	# 返回副本：改返回值不污染内部
	var copy := s.get_linked_evidence("claim_001")
	copy.append("evidence_999")
	_eq(f, "copy isolation", s.get_linked_evidence("claim_001").size(), 2)
	_eq(f, "unlink", s.unlink_evidence("claim_001", "evidence_001"), true)
	_eq(f, "unlinked count", s.get_linked_evidence("claim_001").size(), 1)
	_eq(f, "unlink unknown", s.unlink_evidence("claim_001", "nope"), false)


static func _check_hint(f: Array) -> void:
	var s := CaseSession.new(_make_case())
	s.begin_briefing()
	s.begin_investigation()
	_eq(f, "hint bad id", s.use_hint("nope"), false)
	_eq(f, "hint ok", s.use_hint("hint_001"), true)
	_eq(f, "hint second", s.use_hint("hint_001"), false)


static func _check_submit(f: Array) -> void:
	var s := CaseSession.new(_make_case())
	_eq(f, "submit not started", s.submit_final("revise"), false)
	s.begin_briefing()
	s.begin_investigation()
	_eq(f, "submit not all judged", s.submit_final("revise"), false)
	for i in [1, 2, 3]:
		s.judge_claim("claim_00%d" % i, "unverified")
	_eq(f, "submit ready", s.submit_final("revise"), true)
	_eq(f, "phase submitted", s.phase, CaseSession.Phase.SUBMITTED)
	_eq(f, "submit same idempotent", s.submit_final("revise"), true)
	_eq(f, "submit diff action", s.submit_final("hold"), false)
	_eq(f, "begin_debrief", s.begin_debrief(), true)
	_eq(f, "phase completed", s.phase, CaseSession.Phase.COMPLETED)


static func _check_reset(f: Array) -> void:
	var s := CaseSession.new(_make_case())
	s.begin_briefing()
	s.begin_investigation()
	s.judge_claim("claim_001", "unverified")
	s.link_evidence("claim_001", "evidence_001")
	s.use_hint("hint_001")
	s.reset()
	_eq(f, "reset phase", s.phase, CaseSession.Phase.INVESTIGATING)
	_eq(f, "reset judgements", s.judgements.size(), 0)
	_eq(f, "reset links", s.evidence_links.size(), 0)
	_eq(f, "reset hint", s.hint_used_id, "")


static func _check_roundtrip(f: Array) -> void:
	var s := CaseSession.new(_make_case())
	s.begin_briefing()
	s.begin_investigation()
	s.judge_claim("claim_001", "supported")
	s.link_evidence("claim_001", "evidence_001")
	s.use_hint("hint_001")
	var s2 := CaseSession.from_dict(s.to_dict(), _make_case())
	_eq(f, "roundtrip phase", s2.phase, s.phase)
	_eq(f, "roundtrip judgement", s2.get_judgement("claim_001"), "supported")
	_eq(f, "roundtrip links", s2.get_linked_evidence("claim_001").size(), 1)
	_eq(f, "roundtrip hint", s2.hint_used_id, "hint_001")
