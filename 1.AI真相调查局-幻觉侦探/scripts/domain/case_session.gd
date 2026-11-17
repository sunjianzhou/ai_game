class_name CaseSession
extends RefCounted
# 一案运行时状态：判定、证据关联、提示、最终动作、phase 状态机（纯逻辑）

enum Phase { NOT_STARTED, BRIEFING, INVESTIGATING, READY_TO_SUBMIT, SUBMITTED, COMPLETED }

var case_def: CaseDefinition
var phase: int = Phase.NOT_STARTED
var judgements: Dictionary = {}       # claim_id -> label（string code，覆盖式）
var evidence_links: Dictionary = {}   # claim_id -> Array[String]（去重）
var hint_used_id: String = ""         # 单局至多 1 条
var final_action: String = ""

var _claim_ids: Dictionary = {}
var _evidence_ids: Dictionary = {}


func _init(def: CaseDefinition) -> void:
	case_def = def
	for c in def.claims:
		_claim_ids[c.claim_id] = true
	for e in def.evidence:
		_evidence_ids[e.evidence_id] = true


func begin_briefing() -> bool:
	if phase != Phase.NOT_STARTED:
		return false
	phase = Phase.BRIEFING
	return true


func begin_investigation() -> bool:
	if phase != Phase.BRIEFING:
		return false
	phase = Phase.INVESTIGATING
	return true


func judge_claim(claim_id: String, label: String) -> bool:
	if not _claim_ids.has(claim_id):
		return false
	if Enums.claim_label_value(label) == -1:
		return false
	if phase != Phase.INVESTIGATING and phase != Phase.READY_TO_SUBMIT:
		return false
	judgements[claim_id] = label
	if phase == Phase.INVESTIGATING and all_claims_judged():
		phase = Phase.READY_TO_SUBMIT
	return true


func get_judgement(claim_id: String) -> String:
	return str(judgements.get(claim_id, ""))


func is_judged(claim_id: String) -> bool:
	return judgements.has(claim_id)


func link_evidence(claim_id: String, evidence_id: String) -> bool:
	if not _claim_ids.has(claim_id) or not _evidence_ids.has(evidence_id):
		return false
	if phase != Phase.INVESTIGATING and phase != Phase.READY_TO_SUBMIT:
		return false
	var links: Array = evidence_links.get(claim_id, [])
	if not links.has(evidence_id):
		links.append(evidence_id)
		evidence_links[claim_id] = links
	return true


func unlink_evidence(claim_id: String, evidence_id: String) -> bool:
	if not _claim_ids.has(claim_id) or not _evidence_ids.has(evidence_id):
		return false
	if phase != Phase.INVESTIGATING and phase != Phase.READY_TO_SUBMIT:
		return false
	var links: Array = evidence_links.get(claim_id, [])
	if links.has(evidence_id):
		links.erase(evidence_id)
		evidence_links[claim_id] = links
		return true
	return false


func get_linked_evidence(claim_id: String) -> Array[String]:
	var out: Array[String] = []
	for e in evidence_links.get(claim_id, []):
		out.append(str(e))
	return out


func use_hint(hint_id: String) -> bool:
	if hint_used_id != "":
		return false
	if phase != Phase.INVESTIGATING and phase != Phase.READY_TO_SUBMIT:
		return false
	for h in case_def.hints:
		if h.get("hint_id", "") == hint_id:
			hint_used_id = hint_id
			return true
	return false


func all_claims_judged() -> bool:
	if case_def.claims.is_empty():
		return false
	for c in case_def.claims:
		if not judgements.has(c.claim_id):
			return false
	return true


func submit_final(action: String) -> bool:
	if phase == Phase.READY_TO_SUBMIT:
		if Enums.final_action_value(action) == -1:
			return false
		final_action = action
		phase = Phase.SUBMITTED
		return true
	elif phase == Phase.SUBMITTED:
		return action == final_action
	return false


func begin_debrief() -> bool:
	if phase != Phase.SUBMITTED:
		return false
	phase = Phase.COMPLETED
	return true


func reset() -> void:
	judgements = {}
	evidence_links = {}
	hint_used_id = ""
	final_action = ""
	phase = Phase.INVESTIGATING


func to_dict() -> Dictionary:
	return {
		"phase": phase,
		"judgements": judgements.duplicate(true),
		"evidence_links": evidence_links.duplicate(true),
		"hint_used_id": hint_used_id,
		"final_action": final_action,
	}


static func from_dict(d: Dictionary, def: CaseDefinition) -> CaseSession:
	# 校验：非法即返回 null（草稿是不可信输入）
	var s := CaseSession.new(def)
	var phase := int(d.get("phase", -1))
	if phase != Phase.INVESTIGATING and phase != Phase.READY_TO_SUBMIT and phase != Phase.SUBMITTED:
		return null
	s.phase = phase
	var judgements = d.get("judgements", {})
	if judgements is Dictionary:
		for cid in judgements:
			if not def.claims_by_id.has(cid):
				return null
			if Enums.claim_label_value(str(judgements[cid])) == -1:
				return null
			s.judgements[cid] = str(judgements[cid])
	var links = d.get("evidence_links", {})
	if links is Dictionary:
		for cid in links:
			if not def.claims_by_id.has(cid):
				return null
			var evs: Array = []
			for eid in links[cid]:
				if not def.evidence_by_id.has(str(eid)):
					return null
				evs.append(str(eid))
			s.evidence_links[cid] = evs
	var hint := str(d.get("hint_used_id", ""))
	if hint != "":
		var found := false
		for h in def.hints:
			if str(h.get("hint_id", "")) == hint:
				found = true
				break
		if not found:
			return null
		s.hint_used_id = hint
	s.final_action = str(d.get("final_action", ""))
	return s
