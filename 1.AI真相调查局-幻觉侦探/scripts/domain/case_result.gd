class_name CaseResult
extends RefCounted

var total: int = 0
var earned: float = 0.0
var breakdown: Dictionary = {}   # {accuracy, evidence, final_action}
var hint_penalty: float = 0.0
var hint_used: bool = false
var claims: Array = []           # Array[ClaimResult]
var final_action_detail: Dictionary = {}   # {action, weight, points}
