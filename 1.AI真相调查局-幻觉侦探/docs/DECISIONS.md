# 技术决策记录（DECISIONS）

本文件记录重要技术与产品决策，供后续阶段查询，避免反复重新决策。

## 2026-11-15

1. **git 仓库布局**：顶层 `ai_game/` 为单个 monorepo（整个 AI Playground 系列一个仓库），各游戏为子目录。remote = `github.com/sunjianzhou/ai_game`，身份 `sunjianzhou / 625312906@qq.com`。
2. **引擎版本**：Godot 4.7.2-stable 固定（不用 beta/rc），`config/features=PackedStringArray("4.7","GL Compatibility")`，渲染 `gl_compatibility`。
3. **Autoload 边界类型**：用类型化 DTO（`PlayerProgress`/`CaseLoadResult`/`CaseCatalog`，RefCounted），不用 Dictionary——S1 冻结签名，S2 只加字段/补实现不改签名。
4. **Windows 验收口径**：S1 只验收"导出成功 + 产物齐全（.exe+.pck 非零）"；真机启动/低配/中文路径/无网测试在 S5（本机 macOS 交叉导出无法启动 Windows exe）。与 GDD M0"可运行"的偏差记录在此。
5. **领域枚举**：ClaimLabel 等 9 个领域枚举不在 S1 定义，随 S2 内容 schema 一起定（S1 无内容/评分/UI 使用它们）。
6. **CJK 字体**：Noto Sans CJK SC Regular（SIL OFL 1.1），文件名 `NotoSansCJKsc-Regular.otf`（上游设计文档写的 `NotoSansSC-Regular.ttf` 为概念名，实际 Noto CJK 为 OTF）。
7. **测试运行器**：零第三方依赖，`godot --headless --path . -s res://tests/run_tests.gd`；`run_tests.gd extends SceneTree`，在 `_initialize()` 执行（autoload 此时已注册）。
8. **资源路径**：全小写，严禁大小写混用（Windows 大小写敏感）。
