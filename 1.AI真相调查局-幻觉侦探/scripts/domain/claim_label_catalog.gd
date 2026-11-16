class_name ClaimLabelCatalog
# 四类判定的玩家可读定义（单一来源，供判定按钮/glossary/复盘共用）

const LABELS := {
	"supported": {
		"display_name": "有证据支持",
		"definition": "可靠证据足以支持该陈述。",
		"example": "例：门禁日志显示展厅 C 有访客出入，支持‘对访客开放’。",
	},
	"contradicted": {
		"display_name": "证据矛盾",
		"definition": "可靠证据与陈述直接冲突（从一开始就冲突）。",
		"example": "例：完整登记总账中不存在 TR-204，与‘由 TR-204 批准’矛盾。",
	},
	"unverified": {
		"display_name": "缺乏证据",
		"definition": "现有资料不足以确认、也不足以证伪——不是‘假的’。",
		"example": "例：没有证据覆盖 19:42 的移动，既不能确认也不能排除。",
	},
	"outdated": {
		"display_name": "信息过时",
		"definition": "曾经正确，但已被新资料取代。",
		"example": "例：旧时间表曾正确，但新公告已取代它。",
	},
}
