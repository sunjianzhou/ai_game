class_name SaveLoadResult
extends RefCounted
# 存档加载结果状态机

enum Status { OK, MISSING, CORRUPT, FUTURE_VERSION, MIGRATED }

var status: int = Status.MISSING
var progress: PlayerProgress = null
var file_version: int = 0
var error: String = ""


static func ok(progress: PlayerProgress) -> SaveLoadResult:
	var r := SaveLoadResult.new()
	r.status = Status.OK
	r.progress = progress
	return r


static func missing(progress: PlayerProgress) -> SaveLoadResult:
	var r := SaveLoadResult.new()
	r.status = Status.MISSING
	r.progress = progress
	return r


static func corrupt(progress: PlayerProgress, error: String = "") -> SaveLoadResult:
	var r := SaveLoadResult.new()
	r.status = Status.CORRUPT
	r.progress = progress
	r.error = error
	return r


static func future_version(progress: PlayerProgress, ver: int) -> SaveLoadResult:
	var r := SaveLoadResult.new()
	r.status = Status.FUTURE_VERSION
	r.progress = progress
	r.file_version = ver
	return r
