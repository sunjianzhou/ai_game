# S3 Vertical Slice 详细设计

- 文档版本：v0.2（已按架构师 + 研发工程师 + 无记忆独立复审三轮修订）
- 日期：2026-11-17
- 上游依据：`docs/系统设计.md`（v0.3）、`阶段规划路线.md`（S3）、`AI真相调查局-幻觉侦探研发任务书.md`（Milestone 2）
- 状态：待确认（下一轮交 Gemini 复审）

> S3 = GDD Milestone 2（Vertical Slice）。把 S2 灰盒做成"有质感的调查解谜"。
>
> **v0.2 修订要点**：① 存档重写为可执行契约（`SaveLoadResult` + 未来版本只读 + 事件→写盘表 + 启动加载 + settings 唯一源）；② 草稿归 SaveManager（wrapper + 校验 + phase 路由 + 退出 flush）；③ 补视觉的页面线框 + 材质对比系统（ORION 机器打印件 vs 档案证据）+ 引用 chip；④ 复盘 aha 编排（点击逐条揭晓 + 证据链点亮 + 结案入库）；⑤ 称号补数据 + 评估器；⑥ 导航 phase 守卫；⑦ 判定色彩语义分层 + 虚构 badge + onboarding 完整度 + 无障碍。

---

## 1. 目标与验收标准

**目标**：把 S2 灰盒做成接近最终品质的一段完整体验——主菜单到复盘全程有清晰视觉层级、状态反馈、氛围，进度可保存/恢复。

**验收标准（全部满足才进 S4）**：
1. 主菜单到复盘流程完整，无关键流程阻塞；导航受 phase 守卫（§12），不能绕过状态机直接跳页。
2. 存档可恢复：完成案件后重开，完成状态/最高分/知识卡仍在；中断调查后能"继续上次调查"；**旧版本打开未来版本存档只读拒绝覆盖**。
3. 视觉有"调查卷宗/档案室"质感：报告像机器打印件、证据像档案卡、四类判定用图标+颜色+文字区分、内联陈述有明确视觉状态（§5 线框 + 材质系统）。
4. 1280×720 与 1920×1080、窗口/全屏下布局不错乱；键盘 Tab 可达、焦点可见、判定按钮命中区 ≥44px。
5. 帮助抽屉能解释四类判定与评分规则；首次玩家有完整引导（互动校准 + 锁定其余 claim 的引导 + 为什么反馈 + 首次关联 coach mark）。
6. 图鉴页展示已收集知识卡（含 scope/caveat/依据）与称号。
7. 所有改动不破坏 S2 的回归测试（10 个 `test_*.gd` 全绿）。

---

## 2. 范围

### 2.1 做（S3 交付物）
- 视觉规范（§5：页面线框 + 材质系统 + 四类判定视觉语言 + 四个动作视觉 + DESIGN.md）。
- 主菜单动态背景（优化项，非阻塞）。
- 动效（页面切换、判定反馈、证据 hover、复盘逐条揭晓节奏）。
- 音效（占位接口 + 关键事件接入）。
- 存档（§7：SaveManager 完整契约）。
- 草稿（§8：崩溃恢复）。
- 图鉴页（§9）+ 称号数据 + 评估器。
- 帮助抽屉 + onboarding（§10）。
- 证据交互（§11）。
- 导航 phase 守卫（§12）。
- 无障碍（§13）。

### 2.2 不做（留给 S4+）
- 案件 02/03 内容（S4）。
- Steam 集成、云存档、成就（S6）。
- 完整图鉴跨系列扩展（S4+）。
- 付费、联网、账号（永不）。
- 完整 reduce-motion（S3 记 DESIGN.md，留接口）。

---

## 3. 输入与输出

### 3.1 输入
| 输入 | 来源 | S3 用到 |
|---|---|---|
| 系统设计 v0.3 | `docs/系统设计.md` | §7 图鉴、§8 状态机、§10 存档、§11 UI 规范 |
| S2 代码 | `scripts/`、`scenes/`、`content/` | 领域类型、GameFlow、灰盒 UI、测试 |
| 主题 token | `theme.gd`、`theme.tres` | 色板/间距/字体 |

### 3.2 输出
- 有质感的完整可玩体验 + `DESIGN.md` + 存档/草稿 + 图鉴/称号 + 帮助/教程 + 证据交互 + 导航守卫。

---

## 4. 存档设计（可执行契约）

### 4.1 `SaveLoadResult` 状态机（区分"损坏"与"版本过新"）

```gdscript
enum SaveStatus { OK, MISSING, CORRUPT, FUTURE_VERSION, MIGRATED }
class SaveLoadResult:
  status: SaveStatus
  progress: PlayerProgress    # OK/MIGRATED 时有效
  file_version: int           # 读到的版本
  error: String
```

- `MISSING`（无文件）→ 返回默认 PlayerProgress，可写。
- `CORRUPT`（JSON 语法错 / 缺 version / 关键字段类型错）→ 复制原文件为 `save.corrupt.<时间戳>` → 返回默认，可写。
- `FUTURE_VERSION`（file_version > 当前）→ **不动原文件、不生成 .corrupt、`SaveManager.read_only = true`**，之后 `save()` 直接返回 false；UI 提示"存档来自更新版本，请升级"。**逃生舱**：错误提示里加"清除存档并重新开始"高级按钮（二次确认），否则玩家会陷入"永远版本过新无法玩"的死锁。
- `MIGRATED` → 迁移后返回（v1 从未发布过，S3 声明"不支持 v1，按 CORRUPT 处理"，记 DECISIONS）。

### 4.2 原子写序列（固定）

1. 确保目录存在 → 写 `save.tmp`（`store_string` + `flush()` + `close()` + 检查 `get_error()`）。
2. 删除旧 `.bak` → `rename_absolute(save.json → save.bak)`。
3. `rename_absolute(save.tmp → save.json)`；第 2 步失败则把 `.bak` 改回 `save.json`。
- 加载顺序：`save.json` → 缺失/损坏时尝试 `save.bak` → 再默认。
- 用同目录 `DirAccess.rename_absolute`；Windows 覆盖语义在实机验证（S3 验收）。

### 4.3 事件 → 写盘表（GameFlow 调用）

| 事件 | 写什么 |
|---|---|
| `submit_final` 成功后 | `best_score`（max） |
| `begin_debrief` 成功后 | `completed` + `collected_cards` + `earned_titles` + `last_case_id` |
| `goto(CASE_SELECT)` | 整份 PlayerProgress |
| `NOTIFICATION_WM_CLOSE_REQUEST` / 退出 | flush settings + 草稿 + 整份 PlayerProgress |

### 4.4 启动加载

- `SaveManager.ensure_loaded() -> SaveLoadResult`（懒加载，**不在 autoload `_ready` 读盘**）。
- GameFlow `_ready` 调 `ensure_loaded()` 并采纳 `progress`（替换内存默认），UI 只读它。

### 4.5 settings 唯一源

- 唯一源 = `PlayerProgress.settings`（删除 SaveManager 独立的 `_settings`）。
- `set_setting` 改 `_progress.settings` 并标脏；flush 前先 `ensure_loaded()`，只有 OK/MISSING 才写，CORRUPT/FUTURE_VERSION 不写。
- `save(progress)` 写盘前合并最新 settings；`GameFlow` 不再缓存 volume，改监听 `setting_changed` 或每次取。

---

## 5. 草稿设计（崩溃恢复，归 SaveManager）

### 5.1 职责划分

- **SaveManager**：独占文件 I/O，提供 `save_draft(dict) -> bool`、`load_draft() -> DraftLoadResult`、`clear_draft()`；原子写 + `base_path` 注入 + 损坏回退。
- **GameFlow**：只保留 debounce Timer + 触发点（`judge_claim/link_evidence/unlink_evidence/use_hint` 后）+ 序列化 wrapper + 在 `start_case`/`begin_debrief` 成功时 clear。

### 5.2 草稿 wrapper 与校验

```json
{ "draft_version": 1, "case_id": "case_001", "saved_at": "...", "session": { ...CaseSession.to_dict()... } }
```

- `CaseSession.from_dict(d, def) -> bool`（改返回值）：phase 只允许 INVESTIGATING/READY_TO_SUBMIT；judgements 的 key 必须 ∈ def.claims_by_id、value 是合法标签；evidence_links 指向 def.evidence_by_id；hint id ∈ def.hints；非法即拒绝/丢弃。
- `case_id` 先经 ContentLoader catalog 校验再 `load_case`，案件不存在则丢草稿。

### 5.3 恢复路由

| 草稿 phase | 恢复到 |
|---|---|
| INVESTIGATING / READY_TO_SUBMIT | 调查桌面 |
| SUBMITTED | 结果页（或直接进结果） |

- `GameFlow.resume_draft() -> bool`：`has_resumable_draft() -> {case_id, title, phase}` 供主菜单显示"继续上次调查"；恢复失败（校验拦截、案件内容已变导致 claim/evidence 被删）→ 把草稿重命名 `draft.invalid.<时间戳>` 并优雅回退到该案件初始状态（不崩溃、不静默丢弃）。
- 退出时 flush 草稿（`NOTIFICATION_WM_CLOSE_REQUEST` + `_exit_tree` 兜底，headless no-op）。

---

## 6. 视觉规范（页面级，DESIGN.md 落地）

### 6.1 材质对比系统（本作核心视觉隐喻）

**ORION 报告 = "过度自信的机器打印件"**：等宽字体（编号/日期/引用）、统一排版、页眉页脚（ORION 版本签名、页码、生成时间）、官方口吻。**证据 = "旧纸/扫描档案"**：暖色卡面、来源戳、可靠度依据、手写批注位。玩家要能一眼区分"机器输出"与"人工档案"。

- 报告引用渲染为**可点击的 citation chip**（编号底色高亮）；缺失的引用（如 TR-204 不存在）点击给"来源未找到"反馈——这是案件 01 的 aha 载体。
- **混排对齐**：CJK（Noto Sans SC）与西文等宽字体的基线/字号可能不一致导致上下错位；S3 早期写一个混排测试页验证，必要时用 Theme `font_size`/`LineSpacing` 微调。
- 材质 token（新增）：`color.paper`（暖白 `#e8e0d0`）、`color.paper-ink`（档案墨色）、`color.mono`（等宽字体，OFL 一款，编号/日期用）。

### 6.2 页面线框（调查桌面 / 复盘 / 主菜单）

**调查桌面**（四区域，S2 布局基础上加视觉）：
```
+-----------------------------------------------+
| 案件 #001 · 标题 · 基准时间         [帮助?]     |
| ── 进度点 ●●○ ─────────────────────────────── |
+----------------+------------------------------+
| ORION 报告     |  证据材料（档案卡）           |
| （机器打印件） |  ┌ 标题 · 来源戳 ┐            |
| · 可点陈述     |  │ 时间/可靠度依据  │  ✓/未关联 |
| · citation chip|  └────────────────┘           |
| （内联，状态色）|  [排序][筛选]                |
+----------------+------------------------------+
| 选中陈述面板（判定+关联证据+取消）              |
| [有证据支持][证据矛盾][缺乏证据][信息过时][提示][提交] |
| 虚构案例 · 非真实模型测评                      |
+-----------------------------------------------+
```

**复盘**：逐条卡片，每条 = 陈述文本 + 「你的判定 vs 正确答案」并排 + 解释 + 证据链点亮；结尾"结案"弹层（知识卡 + 称号入库动画）。

**主菜单**：合成构图（分层 UI + 档案夹/台灯/印章占位 + 案件列表），非渐变呼吸。

### 6.3 四类判定视觉语言（语义色与交互色分层）

- **交互色**（focus/current/CTA）与**语义色**（四类判定）分离，避免 `accent` 一色三义。
- 语义：supported=蓝 ✓、contradicted=红 ✗、unverified=**独立色相（如青/灰蓝 + 虚线框，表示"不确定"）**、outdated=琥珀 ⏱。图标用 `assets/icons/` 下的 SVG（不用字符 emoji）。
- 对比度实测 ≥4.5:1（danger 若不足则用浅一档红）。
- 四个最终动作：approve=蓝、approve_with_caveat=琥珀、hold=灰、revise=红（图标+颜色+文案，从 `FinalActionCatalog` 取）。

### 6.4 常驻标识

"虚构案例 · 非真实模型测评"badge 常驻：主菜单、简报、调查、证据查看器、复盘。`test_scene_smoke` 断言。

---

## 7. 动效与音效

### 7.1 动效（克制，Tween）

- 页面切换：新场景根 `modulate` 0→1 淡入（不建全局 autoload）。
- 判定反馈：按钮闪烁（每个按钮保存 `_flash_tween`，kill 上一个）+ pip ● 放大（`pivot_offset = size/2`）。
- 证据 hover：底色变（Tween `modulate` 或 theme 瞬时，记 DESIGN.md）。
- **复盘 aha**：逐条"点击揭晓"（非 0.4s 自动）——先显示玩家判定 + 证据链，玩家点"揭晓"后正确答案+解释浮现（节点绑定 Tween，`tween_callback`），对/错不同编排；结尾"结案"动画（知识卡+称号入库）。结果页只给总分（不剧透）。

### 7.2 音效（占位接口 + 关键接入）

- `AudioManager` 放 **GameFlow 子节点**（不新增 autoload，符合"三 autoload"）；音量接 SaveManager settings；音频用 `ResourceLoader.exists()` 缺失 no-op。
- 事件：click / judge / submit / reveal / error；加一个签名音（判定盖章/揭晓翻页）。占位素材不落空文件。

---

## 8. 图鉴页与称号

### 8.1 图鉴页（Collection）

- 展示已收集知识卡（title + body + **scope + caveat** + references）+ 已获称号 + 未解锁（剪影 + "完成案件 XX 后解锁"）。
- 加"n/N 知识卡、n/N 称号"计数；空/加载/错误状态。
- 从主菜单进入。

### 8.2 称号数据与评估

- 新增 `content/knowledge/titles.json`（schema：`{title_id, name, description, unlock_rule:{type,count}}`，type ∈ {cases_completed, all_cases, no_hint_all_cases}）。
- `ContentLoader.get_titles() -> Array`（替换空桩）。
- Domain 纯函数评估器：`TitleEvaluator.evaluate(titles, progress) -> Array[title_id]`；`begin_debrief` 后调用并写 `earned_titles`。

---

## 9. 帮助与 onboarding

### 9.1 帮助抽屉

- 调查桌面"?"按钮 + 主菜单/简报全局入口（帮助是 overlay，不注册为第 10 页，`PAGE_SCENES` 保持 9）。
- 内容：四类判定定义+例子（`ClaimLabelCatalog`）、评分 60/30/10 + 提示 −5（从常量派生，不复制文本）、操作步骤、证据关联占分。

### 9.2 onboarding（完整，仅首次/案件 01）

- 简报 2 步互动校准：一条样例陈述 + 两张证据卡，先选再解释（样例用能区分 contradicted/unverified 的一组）。
- **首条 claim 强制引导**：锁定其余 claim，四类按钮带一句话定义，判定后立即给"为什么 + 与相邻类别的区别"反馈。
- 首次证据关联 coach mark；关键词/排序轻提示。
- 触发条件：`onboarding_done` 标志（存 settings/save），重玩不再强制，帮助抽屉可重看。
- glossary：帮助抽屉内常驻四类定义（不是"一行"，是抽屉里的完整解释）。

---

## 10. 证据交互（MVP 收敛）

- 排序：按 `created_at` 倒序（ISO 解析失败回退字符串）；筛选：按来源类型。控件用两个 `OptionButton`。
- 单一 `_render_evidence()` 重建函数：`remove_child + queue_free` + `_evidence_buttons.clear()` + 重连信号（evidence_id 存 meta）+ 保留 ✓ 关联。
- 关键词高亮：显式"标记关键词"按钮读 `get_selected_text()`（`selection_enabled=true`，不依赖 meta 点击）；标记为本地状态，进草稿（`draft` 里存标记词）；证据卡命中词整卡高亮（Button 底/边框）。
- 证据卡弱化"可靠度"badge（避免按颜色排序泄题），改为"一手/二手、时间范围"事实标签，reliability_basis 放卡片正文。

---

## 11. 导航 phase 守卫

- `GameFlow.can_goto/goto` 实现上游 §8.3 的"phase → 允许页面"表；非法跳转返回 false 并回退安全页。
- 维护 `previous_page`（设置/帮助返回用）。
- 补非法跳转测试。

---

## 12. 无障碍与适配

- 1280×720 基础（`canvas_items` + `keep` 不变）；验证 1920×1080、窗口拉伸、全屏、最小尺寸。
- 键盘：Tab 遍历 + 焦点可见（新增 `focus` StyleBoxFlat，2px accent 边框）+ 数字键/方向键判定辅助。
- 命中区 ≥44px（判定/提交按钮 `custom_minimum_size.y`）。
- `font_scale` 用根 Theme duplicate，测试后还原（不改 `default_font_size` 的 16，避免 test_s1 红）。
- 对比度核验 ≥4.5:1（`ink-dim`/`danger` 等）。

---

## 13. 测试计划（S3）

- `test_save.gd`：SaveManager 读写往返、原子写、`MISSING/CORRUPT/FUTURE_VERSION` 分支、未来版本只读拒绝覆盖、.bak 回退、settings 写入不覆盖 progress、迁移声明、路径注入（临时目录）。
- `test_draft.gd`：草稿 wrapper 往返、from_dict 校验（非法 phase/id/label/hint 拒绝）、恢复路由（INVESTIGATING/READY/SUBMITTED）、退出 flush、损坏回退。
- `test_titles.gd`：称号评估器（cases_completed/all_cases/no_hint）。
- 回归：S2 的 10 个 `test_*.gd` 全绿（含 `test_scene_smoke` 更新：断言 badge、帮助 overlay 不占页数）。
- `test_offline.gd`（上游要求，S2 遗漏，S3 补）：静态扫描无网络 API。
- 测试隔离：`run_tests.gd` 在所有 case 前设唯一临时目录（`base_path` 注入），结束清理还原；不 autoload `_ready` 读真实档。临时目录后缀用 `Time.get_ticks_usec()` 保证唯一（防并发/快速连续执行的文件占用冲突）。

---

## 14. 目录增量

```text
docs/DESIGN.md
content/knowledge/titles.json
scenes/knowledge/collection.tscn + .gd
scenes/settings/settings.tscn + .gd
scenes/investigation/help_drawer.tscn + .gd
scripts/persistence/save_manager.gd   # 完整契约
scripts/persistence/save_load_result.gd
scripts/domain/title_evaluator.gd
scripts/audio/audio_manager.gd        # GameFlow 子节点
assets/icons/*.svg  assets/backgrounds/  assets/audio/（占位）
tests/test_save.gd  test_draft.gd  test_titles.gd  test_offline.gd
```

---

## 15. 与 S4 的接口

S4（三案内容）复用：领域类型、schema、存档格式、UI 组件、测试运行器；案件 02/03 内容按 schema 写入，不改核心代码；称号/知识卡沿用 S3 评估器与图鉴。

---

## 16. 待定与留给开发者的决策

1. 主菜单背景的合成构图细节（S3 占位分层，正式美术 S3 后期/S4）。
2. 音效正式素材与授权（S3 占位 + 接口）。
3. 等宽字体（报告编号/引用）选型（OFL，如 JetBrains Mono / IBM Plex Mono，S3 定）。
4. 四类判定的 SVG 图标最终形态（S3 定稿）。
5. 关键词高亮进草稿的具体字段（`draft.session` 里加 `marked_keywords`）。
