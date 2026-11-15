extends Node
# 内容加载。S1 空实现；S2 读 content/**/*.json（接口不变）。

var content_root: String = "res://content"     # 路径注入点


func get_catalog() -> CaseCatalog:
	return CaseCatalog.new()


func load_case(id: String) -> CaseLoadResult:
	return CaseLoadResult.failure([{
		"case_id": id,
		"field": "",
		"code": "not_found",
		"message": "case not found (S1 未接入内容)",
	}])


func get_knowledge_cards() -> Dictionary:
	return {"cards": []}


func get_titles() -> Dictionary:
	return {"titles": []}
