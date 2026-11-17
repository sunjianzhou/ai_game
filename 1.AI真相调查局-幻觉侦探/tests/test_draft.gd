# 草稿崩溃恢复测试：from_dict 校验 + draft save/load/clear
const Fixtures = preload("res://tests/test_fixtures.gd")


static func run(tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	var sm = tree.root.get_node("SaveManager")
	var orig: String = sm.base_path
	f.append_array(_check_from_dict())
	# draft save/load/clear
	var base := "user://__test_draft_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(base)
	sm.base_path = base
	sm.read_only = false
	sm.save_draft({"draft_version": 1, "case_id": "case_001", "session": {"phase": 1}})
	var loaded = sm.load_draft()
	_eq(f, "draft roundtrip", int(loaded.get("draft_version", 0)), 1)
	sm.clear_draft()
	_eq(f, "draft cleared", sm.load_draft().is_empty(), true)
	sm.base_path = orig
	return f


static func _check_from_dict() -> Array[String]:
	var f: Array[String] = []
	var def := Fixtures.make_case()
	var s := CaseSession.new(def)
	s.begin_briefing()
	s.begin_investigation()
	s.judge_claim("claim_001", "supported")
	s.link_evidence("claim_001", "evidence_001")
	s.use_hint("hint_001")
	var s2 := CaseSession.from_dict(s.to_dict(), def)
	if s2 == null or s2.get_judgement("claim_001") != "supported":
		f.append("from_dict 合法往返失败")
	if CaseSession.from_dict({"phase": 99, "judgements": {}, "evidence_links": {}}, def) != null:
		f.append("非法 phase 应返回 null")
	if CaseSession.from_dict({"phase": CaseSession.Phase.INVESTIGATING, "judgements": {"nope": "supported"}, "evidence_links": {}}, def) != null:
		f.append("非法 claim id 应返回 null")
	if CaseSession.from_dict({"phase": CaseSession.Phase.INVESTIGATING, "judgements": {"claim_001": "bogus"}, "evidence_links": {}}, def) != null:
		f.append("非法 label 应返回 null")
	if CaseSession.from_dict({"phase": CaseSession.Phase.INVESTIGATING, "judgements": {}, "evidence_links": {}, "hint_used_id": "nope"}, def) != null:
		f.append("非法 hint 应返回 null")
	return f


static func _eq(f: Array, label: String, got, expected) -> void:
	if got != expected:
		f.append("%s = %s，应 %s" % [label, str(got), str(expected)])
