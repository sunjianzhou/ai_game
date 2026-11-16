class_name CaseLoader
extends RefCounted
# JSON → CaseDefinition 解析 + 校验（纯函数，不抛异常）

const CODE_SCHEMA_VERSION := "schema_version_mismatch"
const CODE_DUPLICATE_ID := "duplicate_id"
const CODE_CLAIM_COUNT := "claim_count_out_of_range"
const CODE_KEY_NOT_SUBSET := "key_not_subset_related"
const CODE_MISSING_REF := "missing_reference"
const CODE_INVALID_ENUM := "invalid_enum"
const CODE_INVALID_DATE := "invalid_date"
const CODE_INVALID_DATE_RANGE := "invalid_date_range"
const CODE_OUTDATED_NO_CHAIN := "outdated_no_time_chain"
const CODE_SNAPSHOT_NO_VALID_UNTIL := "snapshot_missing_valid_until"
const CODE_PREFERRED_NOT_IN := "preferred_not_in_accepted"
const CODE_INVALID_WEIGHT := "invalid_score_weight"
const CODE_REPORT_CLAIM_MISSING := "report_claim_missing"
const CODE_REPORT_CLAIM_DUP := "report_claim_duplicate"
const CODE_REPORT_CLAIM_TEXT := "report_claim_with_text"
const CODE_MISSING_TEXT := "missing_text"
const CODE_ANTHROPOMORPHIC := "anthropomorphic_word"
const CODE_INVALID_TABLE := "invalid_table"
const CODE_PARSE_ERROR := "parse_error"
const CODE_KNOWLEDGE_CARD_MISSING := "knowledge_card_missing"

const BANNED_WORDS := ["故意", "撒谎", "意识", "想骗", "欺骗"]


static func parse_case(json_text: String) -> CaseLoadResult:
	var p := JSON.new()
	if p.parse(json_text) != OK:
		return CaseLoadResult.failure([_err("", "", CODE_PARSE_ERROR, "JSON 解析失败: %s" % p.get_error_message())])
	var d = p.data
	if not (d is Dictionary):
		return CaseLoadResult.failure([_err("", "", CODE_PARSE_ERROR, "JSON 顶层非对象")])
	var errors := _validate(d)
	if not errors.is_empty():
		return CaseLoadResult.failure(errors)
	return CaseLoadResult.success(_build(d))


static func _err(case_id: String, field: String, code: String, msg: String) -> Dictionary:
	return {"case_id": case_id, "field": field, "code": code, "message": msg}


static func _validate(d: Dictionary) -> Array:
	var errors: Array = []
	var case_id := str(d.get("case_id", ""))
	if int(d.get("schema_version", 0)) != 2:
		errors.append(_err(case_id, "schema_version", CODE_SCHEMA_VERSION, "schema_version 必须为 2"))
	# claims / evidence
	var claims: Array = d.get("claims", [])
	var evidence: Array = d.get("evidence", [])
	if claims.size() < 3 or claims.size() > 5:
		errors.append(_err(case_id, "claims", CODE_CLAIM_COUNT, "claims 数量须 3–5"))
	var claim_ids := {}
	for c in claims:
		var cid := str(c.get("claim_id", ""))
		if cid == "" or claim_ids.has(cid):
			errors.append(_err(case_id, "claim_id", CODE_DUPLICATE_ID, "claim_id 重复或为空: %s" % cid))
		claim_ids[cid] = true
	var ev_ids := {}
	for e in evidence:
		var eid := str(e.get("evidence_id", ""))
		if eid == "" or ev_ids.has(eid):
			errors.append(_err(case_id, "evidence_id", CODE_DUPLICATE_ID, "evidence_id 重复或为空: %s" % eid))
		ev_ids[eid] = true
	# 每条 claim 校验
	for c in claims:
		var cid := str(c.get("claim_id", ""))
		var correct := str(c.get("correct_label", ""))
		if Enums.claim_label_value(correct) == -1:
			errors.append(_err(case_id, cid + ".correct_label", CODE_INVALID_ENUM, "非法 correct_label: %s" % correct))
		var kind := str(c.get("claim_kind", ""))
		if Enums.claim_kind_value(kind) == -1:
			errors.append(_err(case_id, cid + ".claim_kind", CODE_INVALID_ENUM, "非法 claim_kind: %s" % kind))
		var rp = c.get("reasoning_pattern")
		if rp != null and Enums.reasoning_pattern_value(str(rp)) == -1:
			errors.append(_err(case_id, cid + ".reasoning_pattern", CODE_INVALID_ENUM, "非法 reasoning_pattern: %s" % str(rp)))
		var key: Array = _str_array(c.get("key_evidence_ids", []))
		var related: Array = _str_array(c.get("related_evidence_ids", []))
		if key.is_empty():
			errors.append(_err(case_id, cid + ".key_evidence_ids", CODE_MISSING_REF, "key_evidence_ids 不能为空"))
		for k in key:
			if not ev_ids.has(k):
				errors.append(_err(case_id, cid + ".key_evidence_ids", CODE_MISSING_REF, "key 引用不存在的证据: %s" % k))
			if not related.has(k):
				errors.append(_err(case_id, cid + ".key_evidence_ids", CODE_KEY_NOT_SUBSET, "key 不在 related 中: %s" % k))
		for r in related:
			if not ev_ids.has(r):
				errors.append(_err(case_id, cid + ".related_evidence_ids", CODE_MISSING_REF, "related 引用不存在的证据: %s" % r))
		if str(c.get("explanation", "")) == "":
			errors.append(_err(case_id, cid + ".explanation", CODE_MISSING_TEXT, "explanation 不能为空"))
		# outdated 硬规则
		if correct == "outdated":
			var has_chain := false
			for k in key:
				for e in evidence:
					if str(e.get("evidence_id", "")) == k:
						var vu = e.get("valid_until")
						if vu != null and str(vu) < str(d.get("as_of", "")):
							has_chain = true
			if not has_chain:
				errors.append(_err(case_id, cid, CODE_OUTDATED_NO_CHAIN, "outdated 需要 valid_until < as_of 的时间链"))
	# 每条 evidence 校验
	for e in evidence:
		var eid := str(e.get("evidence_id", ""))
		if Enums.source_type_value(str(e.get("source_type", ""))) == -1:
			errors.append(_err(case_id, eid + ".source_type", CODE_INVALID_ENUM, "非法 source_type"))
		if Enums.record_type_value(str(e.get("record_type", ""))) == -1:
			errors.append(_err(case_id, eid + ".record_type", CODE_INVALID_ENUM, "非法 record_type"))
		if Enums.reliability_value(str(e.get("reliability", ""))) == -1:
			errors.append(_err(case_id, eid + ".reliability", CODE_INVALID_ENUM, "非法 reliability"))
		if Enums.content_format_value(str(e.get("content_format", "text"))) == -1:
			errors.append(_err(case_id, eid + ".content_format", CODE_INVALID_ENUM, "非法 content_format"))
		var vf = e.get("valid_from")
		var vu = e.get("valid_until")
		if vf != null and vu != null and str(vf) > str(vu):
			errors.append(_err(case_id, eid, CODE_INVALID_DATE_RANGE, "valid_from > valid_until"))
		if str(e.get("record_type", "")) == "snapshot" and (vu == null or str(vu).strip_edges() == ""):
			errors.append(_err(case_id, eid, CODE_SNAPSHOT_NO_VALID_UNTIL, "snapshot 需要非空 valid_until"))
		if str(e.get("reliability_basis", "")) == "":
			errors.append(_err(case_id, eid + ".reliability_basis", CODE_MISSING_TEXT, "reliability_basis 不能为空"))
		if str(e.get("content_format", "text")) == "table":
			var table: Dictionary = e.get("table", {})
			var cols: Array = table.get("columns", [])
			var rows: Array = table.get("rows", [])
			if cols.is_empty() or rows.is_empty():
				errors.append(_err(case_id, eid + ".table", CODE_INVALID_TABLE, "table 需要 columns 与 rows"))
		for rel in e.get("relations", []):
			if not claim_ids.has(str(rel.get("claim_id", ""))):
				errors.append(_err(case_id, eid + ".relations", CODE_MISSING_REF, "relation 引用不存在的 claim"))
			if Enums.relation_value(str(rel.get("relation", ""))) == -1:
				errors.append(_err(case_id, eid + ".relations", CODE_INVALID_ENUM, "非法 relation"))
	# 枚举：difficulty
	if Enums.difficulty_value(str(d.get("difficulty", ""))) == -1:
		errors.append(_err(case_id, "difficulty", CODE_INVALID_ENUM, "非法 difficulty"))
	# final_decisions
	var fd: Dictionary = d.get("final_decisions", {})
	var preferred := str(fd.get("preferred_action", ""))
	var accepted: Array = fd.get("accepted_actions", [])
	var has_preferred := false
	var has_full_weight := false
	for a in accepted:
		var act := str(a.get("action", ""))
		if Enums.final_action_value(act) == -1:
			errors.append(_err(case_id, "final_decisions.action", CODE_INVALID_ENUM, "非法 action: %s" % act))
		var w := float(a.get("score_weight", -1.0))
		if w < 0.0 or w > 1.0:
			errors.append(_err(case_id, "final_decisions.score_weight", CODE_INVALID_WEIGHT, "weight 须在 [0,1]"))
		if w == 1.0:
			has_full_weight = true
		if act == preferred:
			has_preferred = true
	if not has_preferred:
		errors.append(_err(case_id, "final_decisions", CODE_PREFERRED_NOT_IN, "preferred_action 不在 accepted_actions 中"))
	if not has_full_weight:
		errors.append(_err(case_id, "final_decisions", CODE_INVALID_WEIGHT, "至少一个动作 weight == 1.0"))
	# report_segments
	var segments: Array = d.get("report", {}).get("segments", [])
	var referenced := {}
	for seg in segments:
		if str(seg.get("type", "")) == "claim":
			var cid := str(seg.get("claim_id", ""))
			if seg.has("text"):
				errors.append(_err(case_id, "report.segments", CODE_REPORT_CLAIM_TEXT, "claim 片段不应带 text"))
			if not claim_ids.has(cid):
				errors.append(_err(case_id, "report.segments", CODE_REPORT_CLAIM_MISSING, "report 引用不存在的 claim: %s" % cid))
			if referenced.has(cid):
				errors.append(_err(case_id, "report.segments", CODE_REPORT_CLAIM_DUP, "claim 被重复引用: %s" % cid))
			referenced[cid] = true
	for cid in claim_ids:
		if not referenced.has(cid):
			errors.append(_err(case_id, "report.segments", CODE_REPORT_CLAIM_MISSING, "claim 未被报告引用: %s" % cid))
	# 文案 + 拟人化词
	if str(d.get("fiction_note", "")) == "":
		errors.append(_err(case_id, "fiction_note", CODE_MISSING_TEXT, "fiction_note 不能为空"))
	var debrief: Dictionary = d.get("debrief", {})
	for key in ["knowledge_title", "knowledge_body", "model_behavior_note"]:
		if str(debrief.get(key, "")) == "":
			errors.append(_err(case_id, "debrief." + key, CODE_MISSING_TEXT, key + " 不能为空"))
	for b in BANNED_WORDS:
		if str(debrief.get("knowledge_body", "")).contains(b):
			errors.append(_err(case_id, "debrief.knowledge_body", CODE_ANTHROPOMORPHIC, "知识解释含拟人化词: %s" % b))
	# hints
	var hints: Array = d.get("hints", [])
	for h in hints:
		if Enums.hint_type_value(str(h.get("type", ""))) == -1:
			errors.append(_err(case_id, "hints.type", CODE_INVALID_ENUM, "非法 hint type"))
	return errors


static func _str_array(v) -> Array[String]:
	var out: Array[String] = []
	if v is Array:
		for x in v:
			if x is String:
				out.append(x)
	return out


static func _build(d: Dictionary) -> CaseDefinition:
	var cd := CaseDefinition.new()
	cd.case_id = str(d.get("case_id", ""))
	cd.title = str(d.get("title", ""))
	cd.difficulty = str(d.get("difficulty", ""))
	cd.order = int(d.get("order", 0))
	cd.as_of = str(d.get("as_of", ""))
	cd.briefing = str(d.get("briefing", ""))
	cd.objectives = _str_array(d.get("objectives", []))
	cd.fiction_note = str(d.get("fiction_note", ""))
	cd.report_segments = d.get("report", {}).get("segments", [])
	for c in d.get("claims", []):
		var claim := ClaimDefinition.new()
		claim.claim_id = str(c.get("claim_id", ""))
		claim.text = str(c.get("text", ""))
		claim.claim_kind = str(c.get("claim_kind", "fact"))
		claim.reasoning_pattern = c.get("reasoning_pattern")
		claim.correct_label = str(c.get("correct_label", ""))
		claim.explanation = str(c.get("explanation", ""))
		claim.key_evidence_ids = _str_array(c.get("key_evidence_ids", []))
		claim.related_evidence_ids = _str_array(c.get("related_evidence_ids", []))
		cd.claims.append(claim)
	for e in d.get("evidence", []):
		var ev := EvidenceDefinition.new()
		ev.evidence_id = str(e.get("evidence_id", ""))
		ev.title = str(e.get("title", ""))
		ev.source_type = str(e.get("source_type", ""))
		ev.record_type = str(e.get("record_type", ""))
		ev.created_at = str(e.get("created_at", ""))
		ev.valid_from = e.get("valid_from")
		ev.valid_until = e.get("valid_until")
		ev.reliability = str(e.get("reliability", ""))
		ev.reliability_basis = str(e.get("reliability_basis", ""))
		ev.is_primary = bool(e.get("is_primary", false))
		ev.content_format = str(e.get("content_format", "text"))
		ev.content = str(e.get("content", ""))
		ev.table = e.get("table", {})
		ev.relations = e.get("relations", [])
		cd.evidence.append(ev)
	cd.final_decisions = d.get("final_decisions", {})
	cd.hints = d.get("hints", [])
	cd.scoring = d.get("scoring", {})
	cd.debrief = d.get("debrief", {})
	cd.build_indexes()
	return cd
