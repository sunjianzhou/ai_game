# 评分单元测试：矩阵 16 格 + 证据命中/遗漏/多余/门控 + 最终动作 + 提示
const Fixtures = preload("res://tests/test_fixtures.gd")


static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	_check_matrix(f)
	_check_evidence(f)
	_check_action(f)
	_check_hint(f)
	return f


static func _eq(f: Array, label: String, got, expected) -> void:
	if absf(float(got) - float(expected)) > 0.001:
		f.append("%s = %s，应 %s" % [label, str(got), str(expected)])


static func _check_matrix(f: Array) -> void:
	var cases := [
		["supported", "supported", 1.0], ["supported", "contradicted", 0.0],
		["supported", "unverified", 0.5], ["supported", "outdated", 0.0],
		["contradicted", "supported", 0.0], ["contradicted", "contradicted", 1.0],
		["contradicted", "unverified", 0.5], ["contradicted", "outdated", 0.0],
		["unverified", "supported", 0.0], ["unverified", "contradicted", 0.0],
		["unverified", "unverified", 1.0], ["unverified", "outdated", 0.0],
		["outdated", "supported", 0.0], ["outdated", "contradicted", 0.0],
		["outdated", "unverified", 0.5], ["outdated", "outdated", 1.0],
	]
	for c in cases:
		_eq(f, "matrix %s→%s" % [c[0], c[1]], ScoringMatrix.coeff(c[0], c[1]), c[2])
	_eq(f, "matrix unknown", ScoringMatrix.coeff("bad", "supported"), 0.0)
	_eq(f, "matrix verify", ScoringMatrix.verify().size(), 0)


static func _check_evidence(f: Array) -> void:
	# 全对（全 key 命中）
	var s := Fixtures.make_session(
		["unverified", "contradicted", "supported"], Fixtures.full_links(), "revise")
	var r := Scorer.score(s, Fixtures.make_case())
	_eq(f, "full evidence", r.breakdown["evidence"], 30.0)
	_eq(f, "full total", r.total, 100)
	# 全对但漏关联 claim_001 一条 key（miss=1 → raw=2/3）
	var s2 := Fixtures.make_session(
		["unverified", "contradicted", "supported"],
		{"claim_001": ["evidence_001", "evidence_004"], "claim_002": ["evidence_003"], "claim_003": ["evidence_002"]},
		"revise")
	var r2 := Scorer.score(s2, Fixtures.make_case())
	_eq(f, "missed key evidence", r2.breakdown["evidence"], 20.0 + 10.0 * (1.0 / 3.0))
	# 门控：全 unverified（仅 claim_001 matched）证据只算 claim_001
	var s3 := Fixtures.make_session(
		["unverified", "unverified", "unverified"], Fixtures.full_links(), "revise")
	var r3 := Scorer.score(s3, Fixtures.make_case())
	_eq(f, "gated evidence", r3.breakdown["evidence"], 10.0)
	_eq(f, "gated accuracy", r3.breakdown["accuracy"], 40.0)
	# 无关证据惩罚：claim_002 额外关联 evidence_001（不在 related）→ unrelated=1，raw=0
	var s4 := Fixtures.make_session(
		["unverified", "contradicted", "supported"],
		{"claim_001": Fixtures.full_links()["claim_001"], "claim_002": ["evidence_003", "evidence_001"], "claim_003": ["evidence_002"]},
		"revise")
	var r4 := Scorer.score(s4, Fixtures.make_case())
	_eq(f, "unrelated penalty", r4.breakdown["evidence"], 20.0)


static func _check_action(f: Array) -> void:
	var base := Fixtures.full_links()
	var s := Fixtures.make_session(["unverified", "contradicted", "supported"], base, "revise")
	_eq(f, "action revise", Scorer.score(s, Fixtures.make_case()).breakdown["final_action"], 10.0)
	var s2 := Fixtures.make_session(["unverified", "contradicted", "supported"], base, "hold")
	_eq(f, "action hold 0.6", Scorer.score(s2, Fixtures.make_case()).breakdown["final_action"], 6.0)
	var s3 := Fixtures.make_session(["unverified", "contradicted", "supported"], base, "approve_with_caveat")
	_eq(f, "action caveat 0.1", Scorer.score(s3, Fixtures.make_case()).breakdown["final_action"], 1.0)
	var s4 := Fixtures.make_session(["unverified", "contradicted", "supported"], base, "approve")
	_eq(f, "action approve 0", Scorer.score(s4, Fixtures.make_case()).breakdown["final_action"], 0.0)


static func _check_hint(f: Array) -> void:
	var base := Fixtures.full_links()
	var s := Fixtures.make_session(["unverified", "contradicted", "supported"], base, "revise", "hint_001")
	var r := Scorer.score(s, Fixtures.make_case())
	_eq(f, "hint total", r.total, 95)
	_eq(f, "hint penalty", r.hint_penalty, 5.0)
	_eq(f, "hint used flag", r.hint_used, true)
	# 低分 + 提示 → total 0
	var s2 := Fixtures.make_session(["supported", "supported", "contradicted"], {}, "approve", "hint_001")
	var r2 := Scorer.score(s2, Fixtures.make_case())
	_eq(f, "low score hint", r2.total, 0)
