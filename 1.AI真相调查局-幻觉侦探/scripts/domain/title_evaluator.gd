class_name TitleEvaluator
# 称号解锁评估（纯函数）

static func evaluate(titles: Array, progress: PlayerProgress, total_cases: int) -> Array:
	var earned: Array = []
	var completed := 0
	for cid in progress.progress:
		if bool(progress.progress[cid].get("completed", false)):
			completed += 1
	for t in titles:
		var rule: Dictionary = t.get("unlock_rule", {})
		var rtype := str(rule.get("type", ""))
		if rtype == "cases_completed" and completed >= int(rule.get("count", 0)):
			earned.append(str(t.get("title_id", "")))
		elif rtype == "all_cases" and total_cases > 0 and completed >= total_cases:
			earned.append(str(t.get("title_id", "")))
	return earned
