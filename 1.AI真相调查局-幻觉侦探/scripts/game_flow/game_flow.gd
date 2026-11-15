extends Node
# 应用编排 + 页面导航。S1 只做页面注册表 + 导航；phase 状态机在 S2。

signal case_started(id)
signal case_state_changed(from, to)
signal case_submitted()
signal case_completed(id)

enum Page {
	MAIN_MENU,
	CASE_SELECT,
	BRIEFING,
	INVESTIGATION,
	FINAL_VERDICT,
	RESULTS,
	DEBRIEF,
	COLLECTION,
	SETTINGS,
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

var current_session = null            # S2 为 CaseSession
var current_result = null             # S2 为 CaseResult
var previous_page: int = -1           # 仅设置页返回用，不承载业务状态
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


func start_case(_id: String) -> bool:
	return false                        # S2 实现


func end_case() -> void:
	current_session = null
	current_result = null
