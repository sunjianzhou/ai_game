extends Node
# 应用编排 + 页面导航 + 状态机 + mutation 转发（Presentation 所有变更经它）

signal case_started(id)
signal case_state_changed(from, to)
signal case_submitted()
signal case_completed(id)

enum Page {
	MAIN_MENU, CASE_SELECT, BRIEFING, INVESTIGATION, FINAL_VERDICT, RESULTS, DEBRIEF, COLLECTION, SETTINGS,
}

const PAGE_SCENES := {
	Page.MAIN_MENU: "res://scenes/menu/main_menu.tscn",
	Page.CASE_SELECT: "res://scenes/case_select/case_select.tscn",
	Page.BRIEFING: "res://scenes/briefing/briefing.tscn",
	Page.INVESTIGATION: "res://scenes/investigation/investigation_desk.tscn",
	Page.FINAL_VERDICT: "res://scenes/verdict/final_verdict.tscn",
	Page.RESULTS: "res://scenes/debrief/results.tscn",
	Page.DEBRIEF: "res://scenes/debrief/debrief.tscn",
	Page.COLLECTION: "res://scenes/knowledge/collection.tscn",
	Page.SETTINGS: "res://scenes/settings/settings.tscn",
}

var current_case_def: CaseDefinition = null
var current_session: CaseSession = null
var current_result: CaseResult = null
var player_progress: PlayerProgress = PlayerProgress.new()
var previous_page: int = -1
var _settings_cache = null
var _catalog_cache = null


func _ready() -> void:
	assert(get_node_or_null("/root/SaveManager") != null, "SaveManager must load before GameFlow")
	assert(get_node_or_null("/root/ContentLoader") != null, "ContentLoader must load before GameFlow")
	_settings_cache = SaveManager.get_setting("volume_master")
	_catalog_cache = ContentLoader.get_catalog()


func can_goto(page: int) -> bool:
	return PAGE_SCENES.has(page)


func goto(page: int) -> bool:
	if not can_goto(page):
		return false
	return get_tree().change_scene_to_file(PAGE_SCENES[page]) == OK


func back() -> bool:
	var target: int = previous_page if previous_page >= 0 else Page.MAIN_MENU
	return goto(target)


func start_case(id: String) -> bool:
	var result: CaseLoadResult = ContentLoader.load_case(id)
	if not result.ok:
		return false
	current_case_def = result.case_def
	current_session = CaseSession.new(current_case_def)
	current_session.begin_briefing()
	current_result = null
	case_started.emit(id)
	return true


func begin_investigation() -> bool:
	if current_session == null:
		return false
	var before := current_session.phase
	var ok := current_session.begin_investigation()
	if ok and current_session.phase != before:
		case_state_changed.emit(before, current_session.phase)
	return ok


func judge_claim(claim_id: String, label: String) -> bool:
	if current_session == null:
		return false
	var before := current_session.phase
	var ok := current_session.judge_claim(claim_id, label)
	if ok and current_session.phase != before:
		case_state_changed.emit(before, current_session.phase)
	return ok


func link_evidence(claim_id: String, evidence_id: String) -> bool:
	if current_session == null:
		return false
	return current_session.link_evidence(claim_id, evidence_id)


func unlink_evidence(claim_id: String, evidence_id: String) -> bool:
	if current_session == null:
		return false
	return current_session.unlink_evidence(claim_id, evidence_id)


func use_hint(hint_id: String) -> bool:
	if current_session == null:
		return false
	return current_session.use_hint(hint_id)


func submit_final(action: String) -> bool:
	if current_session == null:
		return false
	var before := current_session.phase
	var ok := current_session.submit_final(action)
	if ok and before == CaseSession.Phase.READY_TO_SUBMIT:
		current_result = Scorer.score(current_session, current_case_def)
		var case_id := current_case_def.case_id
		var prev: Dictionary = player_progress.progress.get(case_id, {})
		var entry: Dictionary = prev.duplicate()
		entry["best_score"] = maxi(int(entry.get("best_score", 0)), current_result.total)
		player_progress.progress[case_id] = entry
		case_submitted.emit()
	if ok and current_session.phase != before:
		case_state_changed.emit(before, current_session.phase)
	return ok


func begin_debrief() -> bool:
	if current_session == null:
		return false
	var before := current_session.phase
	var ok := current_session.begin_debrief()
	if ok:
		var case_id := current_case_def.case_id
		var prev: Dictionary = player_progress.progress.get(case_id, {})
		var entry: Dictionary = prev.duplicate()
		entry["completed"] = true
		player_progress.progress[case_id] = entry
		var card_id := str(current_case_def.debrief.get("knowledge_card_id", ""))
		if card_id != "" and not player_progress.collected_cards.has(card_id):
			player_progress.collected_cards.append(card_id)
		player_progress.last_case_id = case_id
		case_completed.emit(case_id)
		case_state_changed.emit(before, current_session.phase)
	return ok


func reset_case() -> void:
	if current_session != null:
		current_session.reset()
	current_result = null
	# best_score/completed 保留，不回滚


func end_case() -> void:
	current_case_def = null
	current_session = null
	current_result = null
