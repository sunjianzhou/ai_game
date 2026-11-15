class_name CaseLoadResult
extends RefCounted
# 内容加载结果（S1 最小壳；S2 的 case_def 填成真实 CaseDefinition）

var ok: bool = false
var case_def = null            # S2 为 CaseDefinition；S1 恒 null
var errors: Array = []         # [{ case_id, field, code, message }]


static func success(case_def) -> CaseLoadResult:
	var r := CaseLoadResult.new()
	r.ok = true
	r.case_def = case_def
	r.errors = []
	return r


static func failure(errors: Array) -> CaseLoadResult:
	var r := CaseLoadResult.new()
	r.ok = false
	r.case_def = null
	r.errors = errors
	return r
