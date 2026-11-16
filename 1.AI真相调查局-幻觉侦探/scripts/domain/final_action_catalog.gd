class_name FinalActionCatalog
# 四个最终处理动作的玩家可读描述（单一来源）

const ACTIONS := {
	"approve": {
		"display_name": "批准发布",
		"description": "所有关键陈述都有足够证据。",
	},
	"approve_with_caveat": {
		"display_name": "附带限定发布",
		"description": "保留但须注明不确定性或时间范围。",
	},
	"hold": {
		"display_name": "暂缓发布",
		"description": "关键事实尚未核实。",
	},
	"revise": {
		"display_name": "退回修订",
		"description": "存在明显错误或引用问题。",
	},
}
