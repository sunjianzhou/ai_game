# 反刷分不变量：精确期望值（Spec §11.5）
const Fixtures = preload("res://tests/test_fixtures.gd")


static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	var links := Fixtures.full_links()
	_expect(f, "全对", Fixtures.make_session(["unverified", "contradicted", "supported"], links, "revise"), 100)
	_expect(f, "2对+1cautious", Fixtures.make_session(["unverified", "contradicted", "unverified"], links, "revise"), 80)
	_expect(f, "2对+1错", Fixtures.make_session(["unverified", "contradicted", "contradicted"], links, "revise"), 70)
	_expect(f, "全 unverified", Fixtures.make_session(["unverified", "unverified", "unverified"], links, "revise"), 60)
	_expect(f, "全错+正确动作", Fixtures.make_session(["supported", "supported", "contradicted"], {}, "revise"), 10)
	_expect(f, "全错+错动作", Fixtures.make_session(["supported", "supported", "contradicted"], {}, "approve"), 0)
	# 空 case 防御性
	var empty := CaseDefinition.new()
	var es := CaseSession.new(empty)
	var er := Scorer.score(es, empty)
	if er.total != 0 or er.breakdown.get("accuracy", -1.0) != 0.0:
		f.append("空 case 应为全 0")
	return f


static func _expect(f: Array, label: String, session: CaseSession, expected: int) -> void:
	var r := Scorer.score(session, Fixtures.make_case())
	if r.total != expected:
		f.append("%s = %d，应 %d（earned=%.1f breakdown=%s）" % [label, r.total, expected, r.earned, str(r.breakdown)])
