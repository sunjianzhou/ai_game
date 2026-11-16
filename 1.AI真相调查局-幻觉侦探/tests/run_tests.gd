extends SceneTree
# 零依赖测试运行器。运行方式（在工程根目录）：
#   godot --headless --path . -s res://tests/run_tests.gd
# 退出码 0 = 全部通过；1 = 有失败。

const TestS1 = preload("res://tests/test_s1_skeleton.gd")
const TestDomain = preload("res://tests/test_domain.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	failures.append_array(TestS1.run(self))
	failures.append_array(TestDomain.run(self))
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		for f in failures:
			push_error(f)
		print("%d TEST(S) FAILED" % failures.size())
		quit(1)
