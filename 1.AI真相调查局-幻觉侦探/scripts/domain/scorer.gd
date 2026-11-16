class_name Scorer
# 纯函数评分：60 判定准确度 + 30 证据关联（label 门控 + 每条 claim 均分）+ 10 最终建议，再减提示 −5


static func score(session: CaseSession, case_def: CaseDefinition) -> CaseResult:
	var r := CaseResult.new()
	r.breakdown = {"accuracy": 0.0, "evidence": 0.0, "final_action": 0.0}
	var n: int = case_def.claims.size()
	if n <= 0:
		push_warning("Scorer: 空 case，返回零分")
		return r
	var total_key := 0
	for c in case_def.claims:
		total_key += c.key_evidence_ids.size()
	if total_key <= 0:
		push_warning("Scorer: Σkey_count==0，返回零分")
		return r

	var per_claim_max := 60.0 / n
	var per_claim_ev := 30.0 / n
	var accuracy := 0.0
	var evidence := 0.0
	var scoring: Dictionary = case_def.scoring.get("evidence", {})
	var lam := float(scoring.get("unrelated_penalty", 1.0))
	var mu := float(scoring.get("miss_penalty", 1.0))

	for c in case_def.claims:
		var player_label: String = session.get_judgement(c.claim_id)
		var coeff := ScoringMatrix.coeff(c.correct_label, player_label)
		var matched: bool = coeff == 1.0
		accuracy += per_claim_max * coeff

		var linked: Array[String] = session.get_linked_evidence(c.claim_id)
		var key_set := {}
		for k in c.key_evidence_ids:
			key_set[k] = true
		var related_set := {}
		for rel in c.related_evidence_ids:
			related_set[rel] = true
		var hit := 0
		var hit_ids: Array = []
		var unrelated_ids: Array = []
		var unrelated := 0
		for eid in linked:
			if key_set.has(eid):
				hit += 1
				hit_ids.append(eid)
			elif not related_set.has(eid):
				unrelated += 1
				unrelated_ids.append(eid)
		var miss_ids: Array = []
		for k in c.key_evidence_ids:
			if not linked.has(k):
				miss_ids.append(k)
		var key_count: int = c.key_evidence_ids.size()
		var raw := clampf(float(hit) - lam * minf(float(unrelated), float(key_count)) - mu * float(key_count - hit), 0.0, float(key_count))
		if matched:
			evidence += per_claim_ev * (raw / float(key_count))

		var cr := ClaimResult.new()
		cr.claim_id = c.claim_id
		cr.player_label = player_label
		cr.correct_label = c.correct_label
		cr.matched = matched
		cr.points = per_claim_max * coeff
		cr.max_points = per_claim_max
		cr.player_linked_ids = linked
		cr.key_hit_ids = hit_ids
		cr.key_missed_ids = miss_ids
		cr.unrelated_ids = unrelated_ids
		r.claims.append(cr)

	var chosen := session.final_action
	var preferred := str(case_def.final_decisions.get("preferred_action", ""))
	var weight := 0.0
	var fa := 0.0
	if chosen == preferred:
		fa = 10.0
		weight = 1.0
	else:
		for a in case_def.final_decisions.get("accepted_actions", []):
			if a.get("action", "") == chosen:
				weight = float(a.get("score_weight", 0.0))
				fa = 10.0 * weight
				break

	var earned := accuracy + evidence + fa
	var hint_used: bool = session.hint_used_id != ""
	var total := maxi(0, roundi(earned) - (5 if hint_used else 0))
	r.earned = earned
	r.total = total
	r.breakdown = {"accuracy": accuracy, "evidence": evidence, "final_action": fa}
	r.hint_penalty = earned - float(total)
	r.hint_used = hint_used
	r.final_action_detail = {"action": chosen, "weight": weight, "points": fa}
	return r
