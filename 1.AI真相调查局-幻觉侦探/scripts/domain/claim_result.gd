class_name ClaimResult
extends RefCounted

var claim_id: String = ""
var player_label: String = ""
var correct_label: String = ""
var matched: bool = false        # player_label == correct_label
var points: float = 0.0          # 该 claim 的准确度分（不含证据）
var max_points: float = 0.0      # 60 / n_claims
var player_linked_ids: Array[String] = []   # 玩家实际关联（复盘展示证据链）
var key_hit_ids: Array = []
var key_missed_ids: Array = []
var unrelated_ids: Array = []
