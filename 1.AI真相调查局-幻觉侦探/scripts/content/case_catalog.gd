class_name CaseCatalog
extends RefCounted
# 案件清单（S1 最小壳；来自 content/cases/index.json）

var cases: Array = []   # [{ case_id, title, difficulty, order, unlock_condition, summary }]
