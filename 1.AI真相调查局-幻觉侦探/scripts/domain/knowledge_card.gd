class_name KnowledgeCard
extends RefCounted

var card_id: String = ""
var title: String = ""
var category: String = ""
var icon: String = ""
var body: String = ""
var scope: String = ""          # 适用范围（必填）
var caveat: String = ""
var references: Array = []      # 参考链接（必填）
var last_reviewed: String = ""  # 必填
var reviewer: String = ""
var source_case_id: String = ""
