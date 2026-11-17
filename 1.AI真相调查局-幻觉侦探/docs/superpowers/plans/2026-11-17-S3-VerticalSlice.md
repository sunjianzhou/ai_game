# S3 Vertical Slice 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 把 S2 灰盒做成有质感的调查解谜：完整存档/草稿契约、称号、导航守卫、视觉材质系统、复盘 aha、图鉴、帮助/onboarding、证据交互、无障碍。

**Architecture:** 在 S2 领域层之上：SaveManager 独占文件 I/O（存档+草稿+settings），GameFlow 只编排（debounce/触发/恢复/路由）；TitleEvaluator 纯函数；视觉沿用主题 token 扩展（材质对比 + 引用 chip + 判定色彩）。

**Tech Stack:** Godot 4.7.2 + GDScript；零依赖 headless 测试。

**Spec:** `docs/stages/S3-VerticalSlice-详细设计.md`（v0.2）

## Global Constraints

- 存档：`SaveLoadResult` 状态机（OK/MISSING/CORRUPT/FUTURE_VERSION）；FUTURE_VERSION 只读拒绝覆盖 + 逃生舱；原子写序列（tmp→rename→.bak）；`ensure_loaded()` 懒加载（不 autoload `_ready` 读盘）。
- 草稿归 SaveManager：`{draft_version, case_id, session}` wrapper；`CaseSession.from_dict -> bool` 校验；恢复路由按 phase；恢复失败改名 `.draft.invalid.<时间戳>` 回退。
- settings 唯一源 = `PlayerProgress.settings`；写盘前合并；CORRUPT/FUTURE_VERSION 不写。
- 测试隔离：`base_path` 注入临时目录（后缀 `Time.get_ticks_usec()`）；不污染真实 `user://`。
- 导航 phase 守卫：`can_goto/goto` 按"phase→允许页面"表；`PAGE_SCENES` 保持 9（帮助/图鉴是 overlay/页面，不新增页）。
- 回归：S2 的 10 个 `test_*.gd` 全绿；不改 `default_font_size=16`、不改 1280/`keep`/`gl_compatibility`、不改 autoload 顺序。
- 资源路径全小写；零联网/零第三方依赖。

## Review Focus

1. FUTURE_VERSION 只读被绕过 → 覆盖高版本存档（test: 未来版本 `save()` 返回 false 且文件未动）。
2. 设置写入覆盖真实进度（test: set_setting+save 后 progress 的 best_score 仍在）。
3. 草稿非法状态注入（test: from_dict 对非法 phase/id/label 返回 false）。
4. 导航绕过状态机（test: 非 READY 时 `can_goto(RESULTS)` 返回 false）。
5. 标题/判定按钮命中区 <44px、焦点不可见（test: 场景 smoke 断言 focus style + 按钮高度）。

---

### Task 1: 存档契约（SaveLoadResult + SaveManager 重写）

**Files:**
- Create: `scripts/persistence/save_load_result.gd`
- Modify: `scripts/persistence/save_manager.gd`、`scripts/persistence/player_progress.gd`（from_dict 加版本/类型校验）
- Test: `tests/test_save.gd`（新建 + 注册）

**Interfaces:**
- Produces：`SaveLoadResult`（status/progress/file_version/error）；`SaveManager.ensure_loaded() -> SaveLoadResult`、`save(progress) -> bool`、`read_only: bool`、`get_setting/set_setting`（写 `_progress.settings`）、`base_path` 注入。

- [ ] **Step 1: 写失败测试**（test_save.gd，临时目录注入）：MISSING→默认；CORRUPT→默认+`.corrupt`；FUTURE_VERSION→只读、`save()` false、原文件不动；原子写往返；set_setting 后 save 不覆盖 progress 的 best_score；save_version 缺失判 corrupt。

- [ ] **Step 2: 运行验证失败**

- [ ] **Step 3: 实现** save_load_result.gd + save_manager.gd 完整契约（原子写序列、.bak 回退、FUTURE_VERSION 只读）+ player_progress.from_dict 校验

- [ ] **Step 4: 运行验证通过**

- [ ] **Step 5: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "feat(s3): 存档契约 SaveLoadResult + SaveManager 重写" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`

### Task 2: 草稿（SaveManager draft API + GameFlow 触发/恢复 + from_dict 校验）

**Files:**
- Modify: `scripts/persistence/save_manager.gd`（save_draft/load_draft/clear_draft）、`scripts/domain/case_session.gd`（from_dict -> bool 校验）、`scripts/game_flow/game_flow.gd`（debounce + 触发 + resume_draft + flush）
- Test: `tests/test_draft.gd`（新建 + 注册）

**Interfaces:**
- Produces：`SaveManager.save_draft(dict)/load_draft()/clear_draft()`；`CaseSession.from_dict(d, def) -> bool`；`GameFlow.has_resumable_draft()/resume_draft() -> bool`；草稿 wrapper `{draft_version, case_id, session}`。

- [ ] **Step 1: 写失败测试**（test_draft.gd）：wrapper 往返；from_dict 非法 phase/id/label/hint 拒绝；恢复路由（INVESTIGATING/READY→桌面、SUBMITTED→结果）；恢复失败改名 `.draft.invalid` 回退；退出 flush。

- [ ] **Step 2: 运行验证失败**

- [ ] **Step 3: 实现** SaveManager draft API + CaseSession.from_dict 校验 + GameFlow debounce/触发（judge/link/unlink/hint 后）/resume_draft/clear（start_case/begin_debrief 后）+ 退出 flush（NOTIFICATION_WM_CLOSE_REQUEST + _exit_tree）

- [ ] **Step 4: 运行验证通过**

- [ ] **Step 5: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "feat(s3): 草稿崩溃恢复（归 SaveManager + 校验 + 路由）" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`

### Task 3: 称号（titles.json + TitleEvaluator + 发放）

**Files:**
- Create: `content/knowledge/titles.json`、`scripts/domain/title_evaluator.gd`
- Modify: `scripts/content/content_loader.gd`（get_titles 读 titles.json）、`scripts/game_flow/game_flow.gd`（begin_debrief 发放称号）
- Test: `tests/test_titles.gd`（新建 + 注册）

**Interfaces:**
- Produces：`ContentLoader.get_titles() -> Array`（title 字典）；`TitleEvaluator.evaluate(titles, progress) -> Array[title_id]`（cases_completed/all_cases/no_hint_all_cases）。

- [ ] **Step 1: 写失败测试**（test_titles.gd）：三种 unlock_rule 的评估；begin_debrief 后 earned_titles 含 title_intern。

- [ ] **Step 2: 运行验证失败**

- [ ] **Step 3: 实现** titles.json + title_evaluator.gd + content_loader.get_titles + game_flow 发放

- [ ] **Step 4: 运行验证通过**

- [ ] **Step 5: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "feat(s3): 称号数据 + 评估器 + 发放" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`

### Task 4: 导航 phase 守卫

**Files:**
- Modify: `scripts/game_flow/game_flow.gd`（can_goto/goto 允许页表 + previous_page）
- Test: `tests/test_game_state.gd`（扩展 phase 守卫断言）

**Interfaces:**
- Produces：`GameFlow.can_goto(page) -> bool` 按"phase→允许页面"表；`previous_page` 维护。

- [ ] **Step 1: 写失败测试**（test_game_state.gd）：非 READY 时 `can_goto(RESULTS)` false、`can_goto(INVESTIGATION)` true；`goto` 非法页返回 false。

- [ ] **Step 2: 运行验证失败**

- [ ] **Step 3: 实现** 允许页表 + previous_page

- [ ] **Step 4: 运行验证通过**

- [ ] **Step 5: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "feat(s3): 导航 phase 守卫" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`

### Task 5: 视觉材质系统（DESIGN.md + theme 扩展 + 引用 chip + 判定色彩 + badge）

**Files:**
- Create: `docs/DESIGN.md`
- Modify: `scripts/ui/theme.gd`（补 ink-dim/surface-hover/focus/paper 等 token）、`assets/ui/theme.tres`（focus StyleBoxFlat、hover 色对齐）、`scenes/investigation/investigation_desk.gd/.tscn`（报告 citation chip + 判定色彩已做，补 badge 到全场景）
- Test: `tests/test_scene_smoke.gd`（扩展 badge/focus 断言）

**Interfaces:**
- Produces：DESIGN.md；theme 补 `COLOR_INK_DIM/COLOR_SURFACE_HOVER/COLOR_FOCUS/COLOR_PAPER`；报告引用 chip 渲染（citation chip + 缺失引用"来源未找到"反馈）；四类判定 SVG 图标占位（不落字符 emoji）；虚构 badge 常驻主菜单/简报/调查/证据/复盘。

- [ ] **Step 1: 写失败测试**（test_scene_smoke 扩展）：各页有 FooterBadge/虚构标识；theme 有 focus style。

- [ ] **Step 2: 运行验证失败**

- [ ] **Step 3: 实现** DESIGN.md + theme token + 引用 chip + badge + 判定图标占位

- [ ] **Step 4: 运行验证通过**

- [ ] **Step 5: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "feat(s3): 视觉材质系统（DESIGN.md + 引用 chip + badge + 判定图标）" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`

### Task 6: 复盘 aha + 图鉴页 + 帮助/onboarding

**Files:**
- Modify: `scenes/debrief/debrief.gd/.tscn`（逐条揭晓 + 结案动画）、`scenes/knowledge/collection.tscn + .gd`（图鉴页）、`scenes/investigation/help_drawer.tscn + .gd`、`scenes/briefing/briefing.gd/.tscn`（2 步校准）、`scenes/investigation/investigation_desk.gd`（首条 claim 引导 + 证据关联 coach mark）
- Test: `tests/test_scene_smoke.gd`（扩展 collection/help 断言）

**Interfaces:**
- Consumes: GameFlow、ContentLoader.get_knowledge_cards/get_titles、ClaimLabelCatalog。
- Produces：复盘逐条揭晓（点击揭晓 + 证据链 + 结案入库）；Collection（知识卡含 scope/caveat + 称号 + n/N 计数）；帮助抽屉（overlay，不占页数）；onboarding（校准 + 锁定首条引导 + coach mark）。

- [ ] **Step 1: 写失败测试**（test_scene_smoke 扩展）：collection 有知识卡/称号节点、帮助抽屉存在且不注册为页。

- [ ] **Step 2: 运行验证失败**

- [ ] **Step 3: 实现** 复盘/图鉴/帮助/onboarding

- [ ] **Step 4: 运行验证通过**

- [ ] **Step 5: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "feat(s3): 复盘 aha + 图鉴 + 帮助/onboarding" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`

### Task 7: 证据交互 + 无障碍

**Files:**
- Modify: `scenes/investigation/investigation_desk.gd/.tscn`（排序/筛选 OptionButton + 关键词标记 + 证据卡事实标签）、`assets/ui/theme.tres`（focus + 44px 命中区已在 Task 5）
- Test: `tests/test_scene_smoke.gd`（扩展：排序/筛选控件存在）

**Interfaces:**
- Produces：排序（created_at 倒序）/筛选（来源类型）OptionButton；`_render_evidence()` 重建；关键词标记（`get_selected_text()` + 证据卡高亮 + 进草稿）；键盘数字/方向键判定；按钮命中区 ≥44px。

- [ ] **Step 1: 写失败测试**（test_scene_smoke 扩展）：排序/筛选 OptionButton 存在；判定按钮高度 ≥44。

- [ ] **Step 2: 运行验证失败**

- [ ] **Step 3: 实现** 证据排序/筛选/关键词 + 键盘 + 命中区

- [ ] **Step 4: 运行验证通过**

- [ ] **Step 5: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "feat(s3): 证据交互（排序/筛选/关键词）+ 无障碍" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`

### Task 8: 测试整合 + 回归

**Files:**
- Modify: `tests/run_tests.gd`（临时目录 setup/cleanup + 注册新测试）、`tests/test_offline.gd`（新建）
- Modify: `阶段规划路线.md`（S3 → 完成）、`docs/TEST_PLAN.md`

- [ ] **Step 1: 全量测试** `godot --headless --path . --import && godot --headless --path . -s res://tests/run_tests.gd` Expected: 退出码 0（含 S2 回归 + 新测试）

- [ ] **Step 2: 手动走查** 视觉/动效/存档恢复/复盘 aha（记录到 TEST_PLAN）

- [ ] **Step 3: 更新路线图 + TEST_PLAN**

- [ ] **Step 4: Commit** `git -C /Users/linmiao/work/ai_game add -A && git -C /Users/linmiao/work/ai_game commit -m "test(s3): 集成验证 + 离线扫描 + 路线图更新" -m "Co-Authored-By: Claude Code <noreply@anthropic.com>"`
