class_name CaseDefinition
extends RefCounted

var case_id: String = ""
var title: String = ""
var difficulty: String = ""
var order: int = 0
var as_of: String = ""
var briefing: String = ""
var objectives: Array[String] = []
var fiction_note: String = ""
var report_segments: Array = []   # [{type:"narration"|"claim", text?, claim_id?}]
var claims: Array[ClaimDefinition] = []
var evidence: Array[EvidenceDefinition] = []
var final_decisions: Dictionary = {}
var hints: Array = []   # [{hint_id,type,text}]
var scoring: Dictionary = {}
var debrief: Dictionary = {}
var claims_by_id: Dictionary = {}
var evidence_by_id: Dictionary = {}


func build_indexes() -> void:
	claims_by_id = {}
	evidence_by_id = {}
	for c in claims:
		claims_by_id[c.claim_id] = c
	for e in evidence:
		evidence_by_id[e.evidence_id] = e
