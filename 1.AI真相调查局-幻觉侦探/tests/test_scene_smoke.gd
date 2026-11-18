# 场景冒烟：instantiate 各场景，断言关键节点存在（不触发 _ready，故只查静态节点）
static func run(_tree: SceneTree) -> Array[String]:
	var f: Array[String] = []
	_check(f, "res://scenes/case_select/case_select.tscn", ["CaseList", "BackButton"])
	_check(f, "res://scenes/briefing/briefing.tscn", ["StartButton", "CalibrationStep"])
	_check(f, "res://scenes/investigation/investigation_desk.tscn", ["ReportRichText", "ClaimPips", "EvidenceList", "JudgementBar", "JudgeSupported", "JudgeContradicted", "JudgeUnverified", "JudgeOutdated", "HintButton", "SubmitButton", "FooterBadge", "GlossaryDrawer"])
	_check(f, "res://scenes/verdict/final_verdict.tscn", ["ReviseButton", "HoldButton", "CaveatButton", "ApproveButton"])
	_check(f, "res://scenes/debrief/results.tscn", ["TotalLabel", "HintPenaltyLabel", "FinalActionLabel", "DebriefButton"])
	_check(f, "res://scenes/debrief/debrief.tscn", ["BackButton"])
	_check(f, "res://scenes/investigation/evidence_viewer.tscn", ["LinkButton"])
	_check(f, "res://scenes/error/dev_error_page.tscn", ["ErrorLabel"])
	return f


static func _check(f: Array, path: String, required: Array) -> void:
	var packed = load(path)
	if packed == null:
		f.append("场景无法加载: %s" % path)
		return
	var inst = packed.instantiate()
	for n in required:
		if inst.find_child(n, true) == null:
			f.append("场景 %s 缺节点 %s" % [path, n])
	inst.free()
