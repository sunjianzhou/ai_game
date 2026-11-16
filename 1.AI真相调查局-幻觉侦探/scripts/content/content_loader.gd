extends Node
# 内容加载：读 content/**/*.json → CaseDefinition/知识卡；校验失败返回 CaseLoadResult（不抛异常）

var content_root: String = "res://content"

var _catalog_cache: CaseCatalog = null
var _cards_cache: Array[KnowledgeCard] = []


func get_catalog() -> CaseCatalog:
	if _catalog_cache == null:
		_catalog_cache = _load_catalog()
	return _catalog_cache


func load_case(id: String) -> CaseLoadResult:
	var path := "%s/cases/%s.json" % [content_root, id]
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return CaseLoadResult.failure([{"case_id": id, "field": "", "code": "not_found", "message": "case file not found: %s" % path}])
	var result := CaseLoader.parse_case(file.get_as_text())
	if not result.ok:
		return result
	var card_id := str(result.case_def.debrief.get("knowledge_card_id", ""))
	if card_id != "" and not _has_card(card_id):
		return CaseLoadResult.failure([{"case_id": id, "field": "debrief.knowledge_card_id", "code": CaseLoader.CODE_KNOWLEDGE_CARD_MISSING, "message": "knowledge card not found: %s" % card_id}])
	return result


func get_knowledge_cards() -> Array[KnowledgeCard]:
	if _cards_cache.is_empty():
		_cards_cache = _load_cards()
	return _cards_cache


func get_titles() -> Dictionary:
	return {"titles": []}


func _load_catalog() -> CaseCatalog:
	var cat := CaseCatalog.new()
	var file := FileAccess.open("%s/cases/index.json" % content_root, FileAccess.READ)
	if file == null:
		return cat
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for c in parsed.get("cases", []):
			if Enums.unlock_condition_value(str(c.get("unlock_condition", "always"))) == -1:
				push_warning("非法 unlock_condition，跳过案件: %s" % str(c.get("case_id", "")))
				continue
			cat.cases.append(c)
	return cat


func _load_cards() -> Array[KnowledgeCard]:
	var out: Array[KnowledgeCard] = []
	var file := FileAccess.open("%s/knowledge/knowledge_cards.json" % content_root, FileAccess.READ)
	if file == null:
		return out
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for c in parsed.get("cards", []):
			var card := KnowledgeCard.new()
			card.card_id = str(c.get("card_id", ""))
			card.title = str(c.get("title", ""))
			card.category = str(c.get("category", ""))
			card.icon = str(c.get("icon", ""))
			card.body = str(c.get("body", ""))
			card.scope = str(c.get("scope", ""))
			card.caveat = str(c.get("caveat", ""))
			card.references = c.get("references", [])
			card.last_reviewed = str(c.get("last_reviewed", ""))
			card.reviewer = str(c.get("reviewer", ""))
			card.source_case_id = str(c.get("source_case_id", ""))
			out.append(card)
	return out


func _has_card(card_id: String) -> bool:
	for card in get_knowledge_cards():
		if card.card_id == card_id:
			return true
	return false
