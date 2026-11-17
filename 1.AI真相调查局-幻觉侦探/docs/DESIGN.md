# DESIGN.md — 视觉规范

方向：**调查卷宗 / 数字档案室**。核心材质对比——ORION 报告是"机器打印件"（等宽编号、页眉页脚、官方口吻），档案证据是"旧纸/扫描件"（暖色卡面、来源戳、批注位）。

## 色板

| token | hex | 用途 |
|---|---|---|
| color.bg | `#141821` | 冷灰蓝底 |
| color.surface | `#1f2632` | 面板/档案卡面 |
| color.surface-hover | `#2a3442` | 卡片 hover |
| color.ink | `#e6e9ef` | 正文 |
| color.ink-dim | `#8a93a5` | 次要文字/标签 |
| color.accent | `#4a90d9` | 强调/焦点/主 CTA |
| color.danger | `#d9534f` | 矛盾 |
| color.warning | `#e0a13f` | 过时/未证实 |
| color.paper | `#e8e0d0` | 档案纸（暖白） |
| color.paper-ink | `#3a3530` | 档案墨色 |

## 字体与字号

- 正文 Noto Sans CJK SC（16px，行高 1.5）；标题 24px；标签 14px。
- 报告编号/日期/引用用等宽字体（OFL，待定型：JetBrains Mono / IBM Plex Mono）。

## 间距

4px scale（4/8/12/16/24/32）；面板内边距 16，页面外边距 24。

## 四类判定视觉语言（图标+颜色+文字）

| 判定 | 图标 | 颜色 |
|---|---|---|
| supported | ✓ | accent 蓝 |
| contradicted | ✗ | danger 红 |
| unverified | ?（虚线框） | 独立青/灰蓝（区别于 outdated） |
| outdated | ⏱ | warning 琥珀 |

最终动作：approve 蓝 / approve_with_caveat 琥珀 / hold 灰 / revise 红。

## 反 AI 味护栏

不用紫蓝渐变/发光/霓虹；不用三列 icon-in-circle 卡片网格；不用 emoji 当图标；卡片只在"卡片即交互"时用。

## 无障碍

对比度 ≥4.5:1；焦点可见（accent 2px 边框）；命中区 ≥44px；状态不只靠颜色。
