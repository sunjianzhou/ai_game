# 每案评分 fixture：全对（正确标签 + 全 key 证据 + 首选动作）= 100
static func run(tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	var loader = tree.root.get_node("ContentLoader")
	for cid in ["case_001", "case_002", "case_003"]:
		var result = loader.load_case(cid)
		if not result.ok:
			f.append("%s 加载失败: %s" % [cid, str(result.errors)])
			continue
		var def = result.case_def
		var s := CaseSession.new(def)
		s.begin_briefing()
		s.begin_investigation()
		for c in def.claims:
			s.judge_claim(c.claim_id, c.correct_label)
			for eid in c.key_evidence_ids:
				s.link_evidence(c.claim_id, eid)
		s.submit_final(str(def.final_decisions.get("preferred_action", "")))
		var r = Scorer.score(s, def)
		if r.total != 100:
			f.append("%s 全对应 100，实际 %d（%s）" % [cid, r.total, str(r.breakdown)])
	return f
