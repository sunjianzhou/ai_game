class_name Enums
# 12 个枚举 + name/value 辅助（领域内 string code 是唯一表示，enum int 仅用于目录/排序）

enum ClaimLabel { supported, contradicted, unverified, outdated }
enum FinalAction { approve, approve_with_caveat, hold, revise }
enum ClaimKind { fact, calculation, inference }
enum ReasoningPattern { correlation, causation, subset_vs_total, other }
enum SourceType { primary_record, official_announcement, internal_note, report, dataset, other }
enum Reliability { high, medium, low }
enum Difficulty { easy, medium, hard }
enum HintType { direction, evidence, concept }
enum ContentFormat { text, table }
enum RecordType { snapshot, log, registry, handover, note }
enum Relation { supports, contradicts, context, checked_no_match }
enum UnlockCondition { always, prev_case_completed }

const CLAIM_LABEL_NAMES := ["supported", "contradicted", "unverified", "outdated"]
const FINAL_ACTION_NAMES := ["approve", "approve_with_caveat", "hold", "revise"]
const CLAIM_KIND_NAMES := ["fact", "calculation", "inference"]
const REASONING_PATTERN_NAMES := ["correlation", "causation", "subset_vs_total", "other"]
const SOURCE_TYPE_NAMES := ["primary_record", "official_announcement", "internal_note", "report", "dataset", "other"]
const RELIABILITY_NAMES := ["high", "medium", "low"]
const DIFFICULTY_NAMES := ["easy", "medium", "hard"]
const HINT_TYPE_NAMES := ["direction", "evidence", "concept"]
const CONTENT_FORMAT_NAMES := ["text", "table"]
const RECORD_TYPE_NAMES := ["snapshot", "log", "registry", "handover", "note"]
const RELATION_NAMES := ["supports", "contradicts", "context", "checked_no_match"]
const UNLOCK_CONDITION_NAMES := ["always", "prev_case_completed"]


static func _name(names: Array, v: int) -> String:
	return names[v] if v >= 0 and v < names.size() else ""


static func _value(names: Array, s: String) -> int:
	return names.find(s)


static func claim_label_name(v: int) -> String:
	return _name(CLAIM_LABEL_NAMES, v)


static func claim_label_value(s: String) -> int:
	return _value(CLAIM_LABEL_NAMES, s)


static func final_action_name(v: int) -> String:
	return _name(FINAL_ACTION_NAMES, v)


static func final_action_value(s: String) -> int:
	return _value(FINAL_ACTION_NAMES, s)


static func claim_kind_name(v: int) -> String:
	return _name(CLAIM_KIND_NAMES, v)


static func claim_kind_value(s: String) -> int:
	return _value(CLAIM_KIND_NAMES, s)


static func reasoning_pattern_name(v: int) -> String:
	return _name(REASONING_PATTERN_NAMES, v)


static func reasoning_pattern_value(s: String) -> int:
	return _value(REASONING_PATTERN_NAMES, s)


static func source_type_name(v: int) -> String:
	return _name(SOURCE_TYPE_NAMES, v)


static func source_type_value(s: String) -> int:
	return _value(SOURCE_TYPE_NAMES, s)


static func reliability_name(v: int) -> String:
	return _name(RELIABILITY_NAMES, v)


static func reliability_value(s: String) -> int:
	return _value(RELIABILITY_NAMES, s)


static func difficulty_name(v: int) -> String:
	return _name(DIFFICULTY_NAMES, v)


static func difficulty_value(s: String) -> int:
	return _value(DIFFICULTY_NAMES, s)


static func hint_type_name(v: int) -> String:
	return _name(HINT_TYPE_NAMES, v)


static func hint_type_value(s: String) -> int:
	return _value(HINT_TYPE_NAMES, s)


static func content_format_name(v: int) -> String:
	return _name(CONTENT_FORMAT_NAMES, v)


static func content_format_value(s: String) -> int:
	return _value(CONTENT_FORMAT_NAMES, s)


static func record_type_name(v: int) -> String:
	return _name(RECORD_TYPE_NAMES, v)


static func record_type_value(s: String) -> int:
	return _value(RECORD_TYPE_NAMES, s)


static func relation_name(v: int) -> String:
	return _name(RELATION_NAMES, v)


static func relation_value(s: String) -> int:
	return _value(RELATION_NAMES, s)


static func unlock_condition_name(v: int) -> String:
	return _name(UNLOCK_CONDITION_NAMES, v)


static func unlock_condition_value(s: String) -> int:
	return _value(UNLOCK_CONDITION_NAMES, s)
