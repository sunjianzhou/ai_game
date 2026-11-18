extends SceneTree
# 零依赖测试运行器。运行方式（在工程根目录）：
#   godot --headless --path . -s res://tests/run_tests.gd
# 退出码 0 = 全部通过；1 = 有失败。

const TestS1 = preload("res://tests/test_s1_skeleton.gd")
const TestDomain = preload("res://tests/test_domain.gd")
const TestGameState = preload("res://tests/test_game_state.gd")
const TestScoring = preload("res://tests/test_scoring.gd")
const TestScoringInvariants = preload("res://tests/test_scoring_invariants.gd")
const TestContentQuality = preload("res://tests/test_content_quality.gd")
const TestCaseValidation = preload("res://tests/test_case_validation.gd")
const TestCaseCatalog = preload("res://tests/test_case_catalog.gd")
const TestSceneSmoke = preload("res://tests/test_scene_smoke.gd")
const TestSave = preload("res://tests/test_save.gd")
const TestDraft = preload("res://tests/test_draft.gd")
const TestTitles = preload("res://tests/test_titles.gd")
const TestOffline = preload("res://tests/test_offline.gd")
const TestCaseScoring = preload("res://tests/test_case_scoring.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	failures.append_array(TestS1.run(self))
	failures.append_array(TestDomain.run(self))
	failures.append_array(TestGameState.run(self))
	failures.append_array(TestScoring.run(self))
	failures.append_array(TestScoringInvariants.run(self))
	failures.append_array(TestContentQuality.run(self))
	failures.append_array(TestCaseValidation.run(self))
	failures.append_array(TestCaseCatalog.run(self))
	failures.append_array(TestSceneSmoke.run(self))
	failures.append_array(TestSave.run(self))
	failures.append_array(TestDraft.run(self))
	failures.append_array(TestTitles.run(self))
	failures.append_array(TestOffline.run(self))
	failures.append_array(TestCaseScoring.run(self))
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		for f in failures:
			push_error(f)
		print("%d TEST(S) FAILED" % failures.size())
		quit(1)
