class_name ScoringMatrix
# 4×4 非对称矩阵（correct × player），string code 为键

const COEFF := {
	"supported": {"supported": 1.0, "contradicted": 0.0, "unverified": 0.5, "outdated": 0.0},
	"contradicted": {"supported": 0.0, "contradicted": 1.0, "unverified": 0.5, "outdated": 0.0},
	"unverified": {"supported": 0.0, "contradicted": 0.0, "unverified": 1.0, "outdated": 0.0},
	"outdated": {"supported": 0.0, "contradicted": 0.0, "unverified": 0.5, "outdated": 1.0},
}

const LABELS := ["supported", "contradicted", "unverified", "outdated"]


static func coeff(correct: String, player: String) -> float:
	var row: Dictionary = COEFF.get(correct, {})
	return float(row.get(player, 0.0))


static func verify() -> Array[String]:
	var f: Array[String] = []
	for c in LABELS:
		if not COEFF.has(c):
			f.append("矩阵缺行 %s" % c)
		else:
			for p in LABELS:
				if not COEFF[c].has(p):
					f.append("矩阵缺格 %s→%s" % [c, p])
	return f
