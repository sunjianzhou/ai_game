class_name FinalActionCatalog
# 四个最终处理动作的玩家可读描述（单一来源）

const ACTIONS := {
	"approve": {
		"display_name": "批准发布",
		"description": "直接发布，报告没有问题。",
	},
	"approve_with_caveat": {
		"display_name": "附带限定发布",
		"description": "可以发布，但要标注报告里不确定的部分。",
	},
	"hold": {
		"display_name": "暂缓发布",
		"description": "先别发布，等关键事实核实清楚。",
	},
	"revise": {
		"display_name": "退回修订",
		"description": "打回报告，让 AI 修改里面的错误。",
	},
}
