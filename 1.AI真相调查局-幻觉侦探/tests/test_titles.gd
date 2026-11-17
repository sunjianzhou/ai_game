# 称号评估 + 发放测试
static func run(tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	var titles := [
		{"title_id": "title_intern", "name": "见习调查员", "unlock_rule": {"type": "cases_completed", "count": 1}},
		{"title_id": "title_fact_checker", "name": "事实核查员", "unlock_rule": {"type": "all_cases"}},
	]
	var pp := PlayerProgress.new()
	pp.progress["case_001"] = {"completed": true, "best_score": 50}
	var earned := TitleEvaluator.evaluate(titles, pp, 3)
	if not earned.has("title_intern"):
		f.append("cases_completed 应解锁 title_intern")
	if earned.has("title_fact_checker"):
		f.append("all_cases 未完成全部不应解锁")
	var pp2 := PlayerProgress.new()
	for cid in ["case_001", "case_002", "case_003"]:
		pp2.progress[cid] = {"completed": true}
	var earned2 := TitleEvaluator.evaluate(titles, pp2, 3)
	if not earned2.has("title_fact_checker"):
		f.append("all_cases 应解锁 title_fact_checker")
	var loader = tree.root.get_node("ContentLoader")
	if loader.get_titles().is_empty():
		f.append("get_titles 应读 titles.json")
	return f
