class_name WaitToken extends RefCounted

var timer: SceneTreeTimer
var _canceled: bool = false

func _init(timer: SceneTreeTimer) -> void:
	self.timer = timer

func wait() -> void: 
	if timer.time_left >= 0:
		await timer.timeout

func is_canceled() -> bool: return _canceled
	
func cancel() -> void:
	_canceled = true
