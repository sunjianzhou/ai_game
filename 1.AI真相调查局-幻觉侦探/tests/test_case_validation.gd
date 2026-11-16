# ContentLoader/CaseLoader 全量校验：正例 + 负例（每类错误一个）
static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	# 正例
	var ok := CaseLoader.parse_case(_read("res://content/cases/case_001.json"))
	if not ok.ok:
		f.append("case_001 应校验通过: %s" % str(ok.errors))
	# 负例
	var d := _base()
	d["schema_version"] = 1
	_check(f, "schema_version", d, CaseLoader.CODE_SCHEMA_VERSION)

	d = _base()
	d["claims"][0]["claim_id"] = d["claims"][1]["claim_id"]
	_check(f, "duplicate_id", d, CaseLoader.CODE_DUPLICATE_ID)

	d = _base()
	d["claims"] = d["claims"].slice(0, 2)
	_check(f, "claim_count", d, CaseLoader.CODE_CLAIM_COUNT)

	d = _base()
	d["claims"][0]["related_evidence_ids"] = ["evidence_001"]  # key 不在 related
	_check(f, "key_not_subset", d, CaseLoader.CODE_KEY_NOT_SUBSET)

	d = _base()
	d["claims"][0]["correct_label"] = "bogus"
	_check(f, "invalid_enum", d, CaseLoader.CODE_INVALID_ENUM)

	d = _base()
	d["evidence"][0]["valid_until"] = null  # snapshot 缺 valid_until
	_check(f, "snapshot_no_until", d, CaseLoader.CODE_SNAPSHOT_NO_VALID_UNTIL)

	d = _base()
	d["final_decisions"]["preferred_action"] = "nonexistent"
	_check(f, "preferred_not_in", d, CaseLoader.CODE_PREFERRED_NOT_IN)

	d = _base()
	d["final_decisions"]["accepted_actions"][0]["score_weight"] = 1.5
	_check(f, "invalid_weight", d, CaseLoader.CODE_INVALID_WEIGHT)

	d = _base()
	var segs: Array = []
	for seg in d["report"]["segments"]:
		if str(seg.get("claim_id", "")) != "claim_001":
			segs.append(seg)
	d["report"]["segments"] = segs
	_check(f, "report_claim_missing", d, CaseLoader.CODE_REPORT_CLAIM_MISSING)

	d = _base()
	d["claims"][0]["explanation"] = ""
	_check(f, "missing_text", d, CaseLoader.CODE_MISSING_TEXT)

	d = _base()
	d["debrief"]["knowledge_body"] = "AI 故意撒谎"
	_check(f, "anthropomorphic", d, CaseLoader.CODE_ANTHROPOMORPHIC)

	var bad := CaseLoader.parse_case("not valid json {{{")
	if bad.ok or bad.errors.is_empty() or str(bad.errors[0].get("code", "")) != CaseLoader.CODE_PARSE_ERROR:
		f.append("parse_error 应返回 parse 错误码")
	return f


static func _base() -> Dictionary:
	return JSON.parse_string(_read("res://content/cases/case_001.json"))


static func _check(f: Array, label: String, d: Dictionary, code: String) -> void:
	var r := CaseLoader.parse_case(JSON.stringify(d))
	if r.ok:
		f.append("%s 应校验失败" % label)
		return
	var codes := []
	for e in r.errors:
		codes.append(str(e.get("code", "")))
	if not codes.has(code):
		f.append("%s 应含错误码 %s，实际 %s" % [label, code, str(codes)])


static func _read(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()
