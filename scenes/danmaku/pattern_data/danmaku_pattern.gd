class_name DanmakuPattern extends RefCounted

signal finished

## number of points inside the pattern
var bullet_num: int = 0

var _starting: bool = false
func is_starting() -> bool: return _starting

var _callback: Callable
var _sum_delta: float
var _bullet_count: float
var _callback_interval: float

func bake() -> Variant:
	push_error("ERROR: bake() not implemented")
	return []
	
func start(duration: float, callback: Callable) -> Signal:
	_starting = true
	_bullet_count = 0
	_callback = callback
	_callback_interval = duration / bullet_num
	_sum_delta = _callback_interval 
	return finished

func _handle_callback(recover_delta: float, bullet_index: int, callback: Callable) -> void:
	push_error("ERROR: _handle_callback(recover_delta: float, bullet_index: int, callback: Callable) not implemented")
	
func _process(delta: float) -> void:
	_sum_delta += delta
	while _sum_delta >= _callback_interval:
		_sum_delta -= _callback_interval
		_handle_callback(_sum_delta, _bullet_count, _callback)
		_bullet_count += 1
		if _bullet_count >= bullet_num:
			finished.emit()
			_starting = false
			_callback = Callable()
			return
