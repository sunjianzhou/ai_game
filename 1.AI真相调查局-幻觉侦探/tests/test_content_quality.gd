# 内容质量门（纯数据校验，不依赖 ContentLoader）
static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	var case_json: Dictionary = _load_json("res://content/cases/case_001.json")
	if case_json.is_empty():
		f.append("case_001.json 无法解析")
		return f
	# 含 contradicted + unverified
	var labels := {}
	for c in case_json.get("claims", []):
		labels[str(c.get("correct_label", ""))] = true
	if not labels.has("contradicted") or not labels.has("unverified"):
		f.append("case_001 应同时含 contradicted 与 unverified")
	if str(case_json.get("fiction_note", "")) == "":
		f.append("缺 fiction_note")
	# 报告 claim 片段不带 text
	for seg in case_json.get("report", {}).get("segments", []):
		if str(seg.get("type", "")) == "claim" and seg.has("text"):
			f.append("report claim 片段不应带 text")
	# debrief 知识解释无拟人化词
	var banned := ["故意", "撒谎", "意识", "想骗", "欺骗"]
	for b in banned:
		if str(case_json.get("debrief", {}).get("knowledge_body", "")).contains(b) \
				or str(case_json.get("debrief", {}).get("model_behavior_note", "")).contains(b):
			f.append("debrief 含拟人化词 %s" % b)
	# 知识卡
	var cards: Dictionary = _load_json("res://content/knowledge/knowledge_cards.json")
	if cards.is_empty():
		f.append("knowledge_cards.json 无法解析")
	else:
		for c in cards.get("cards", []):
			if str(c.get("scope", "")) == "" or (c.get("references", []) as Array).is_empty() or str(c.get("last_reviewed", "")) == "":
				f.append("知识卡 %s 缺 scope/references/last_reviewed" % str(c.get("card_id", "?")))
	return f


static func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null or not (parsed is Dictionary):
		return {}
	return parsed
