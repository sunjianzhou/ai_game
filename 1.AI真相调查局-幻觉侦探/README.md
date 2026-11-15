# 《AI 真相调查局：幻觉侦探》

单机、离线、2D UI 解谜游戏（Godot 4.7 + GDScript）。玩家扮演 AI 事实调查机构调查员，审查 AI 助手 ORION 生成的报告，判断陈述是否有证据支持、证据矛盾、缺乏证据或已过时。

> 工程文档见 `docs/`：`系统设计.md`（整体设计）、`stages/S1-项目骨架-详细设计.md`（当前阶段）。

## 一、安装 Godot（一次性）

安装 **Godot 4.7.2**（官网 archive 下载 `.app`，macOS 放 `/Applications/Godot.app`）。**不用 beta/rc**。导出 Windows 还需下载匹配版本的导出模板。

## 二、首次导入

```bash
godot --headless --path . --import
```

## 三、运行

```bash
godot --path .
```

## 四、测试

```bash
godot --headless --path . -s res://tests/run_tests.gd
```

退出码 0 = 全部通过。

## 五、导出 Windows

```bash
godot --headless --path . --export-release "Windows Desktop" build/windows/ai_truth_bureau.exe
```

产物：`build/windows/ai_truth_bureau.exe` + `ai_truth_bureau.pck`。

> macOS 若 `godot` 不在 PATH，用 `/Applications/Godot.app/Contents/MacOS/Godot` 替换上面的 `godot`。

## 约定

- 资源路径**全小写**，严禁大小写混用（Windows 文件系统大小写敏感）。
- 存档仅在本地 `user://`；无账号、无网络、无遥测。
