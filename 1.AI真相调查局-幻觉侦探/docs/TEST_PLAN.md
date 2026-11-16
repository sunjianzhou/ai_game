# 测试计划（TEST_PLAN）

记录各阶段测试用例与实际结果。格式：用例 | 命令/步骤 | 期望 | 实际结果 | 日期。

## S1 项目骨架

| 用例 | 命令/步骤 | 期望 | 实际 | 日期 |
|---|---|---|---|---|
| headless 自动化测试 | `godot --headless --path . -s res://tests/run_tests.gd` | 退出码 0 | ✅ 退出码 0 | 2026-11-15 |
| Windows 导出 | 导出命令 | .exe + .pck 非零 | ✅ 104M + 14M | 2026-11-15 |

## S2 单案灰盒

| 用例 | 命令/步骤 | 期望 | 实际 | 日期 |
|---|---|---|---|---|
| headless 全量测试 | `godot --headless --path . -s res://tests/run_tests.gd` | 退出码 0 | ✅ 退出码 0（9 个测试文件） | 2026-11-16 |
| 评分精确期望值 | test_scoring + test_scoring_invariants | 100/80/70/60/10/0 | ✅ 全绿 | 2026-11-16 |
| schema 校验负例 | test_case_validation | 12 类错误各一负例 | ✅ 全绿 | 2026-11-16 |
| 案件目录/解锁 | test_case_catalog | case_999 只加数据 | ✅ 全绿 | 2026-11-16 |
| 内容质量门 | test_content_quality | 无拟人化词/有 scope | ✅ 全绿 | 2026-11-16 |
| 场景冒烟 | test_scene_smoke | 8 场景节点齐全 | ✅ 全绿 | 2026-11-16 |

## 待办：S2 灰盒试玩反馈收集表（进 S3 前）

| 指标 | 目标 |
|---|---|
| 无指导完成率 | 5–10 名目标用户独立完成案件 01 |
| 耗时 | 10–20 分钟 |
| unverified vs contradicted | 是否卡壳（记录） |
| 是否愿意继续下一案 | 是/否 |
