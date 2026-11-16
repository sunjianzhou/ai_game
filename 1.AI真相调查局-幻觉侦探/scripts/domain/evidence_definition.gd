class_name EvidenceDefinition
extends RefCounted

var evidence_id: String = ""
var title: String = ""
var source_type: String = ""
var record_type: String = ""   # snapshot/log/registry/handover/note
var created_at: String = ""    # ISO 日期或日期时间
var valid_from: Variant = null  # null 表无限早
var valid_until: Variant = null  # null 表无限晚
var reliability: String = ""
var reliability_basis: String = ""  # 覆盖范围/依据（必填）
var is_primary: bool = false
var content_format: String = "text"  # text/table
var content: String = ""
var table: Dictionary = {}            # {columns:[], rows:[[]]}；text 时为空
var relations: Array = []             # [{claim_id, relation}] 复盘/校验用，不向玩家展示
