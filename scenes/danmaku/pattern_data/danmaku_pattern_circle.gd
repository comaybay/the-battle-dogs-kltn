class_name DanmakuPatternCircle extends DanmakuPattern

const TwoPI: float = 2.0 * PI

var origin: Vector2 = Vector2.ZERO
var radius: float = 0.0

## number of points inside the circle pattern
var bullet_num: int = 0

## or if number of bullets is not known, you can use step instead (the density of this bullet)
var step: float:
	get: return (TwoPI * destination - TwoPI * start) / bullet_num
	set(value): bullet_num = int((TwoPI * destination - TwoPI * start) / value)

## in radiant
var angle_offset: float = 0.0
## the stating part of the circle pattern
var start: float = 0.0
## the destination of the circle pattern
var destination: float = 1.0

var clockwise_direction: bool = true

var _duration: float
var _callback: Callable
var _sum_delta: float
var _bullet_count: float
var _callback_interval: float

## callback(position, angle (in radiant), passed_delta, index)	
func tween(duration: float, delay: float, callback: Callable) -> Signal:
	set_process(true)
	_bullet_count = 0
	_duration = duration
	_callback = callback
	_callback_interval = duration / bullet_num
	_sum_delta = -delay + _callback_interval 
	return finished;

func _process(delta: float) -> void:
	_sum_delta += delta
	while _sum_delta >= _callback_interval:
		_sum_delta -= _callback_interval
		var start_angle = angle_offset + start * step
		var angle: float = start_angle + _bullet_count * step * (int(clockwise_direction) * 2 - 1)
		var offset := Vector2(radius, 0).rotated(angle)
	
		_callback.call(
			origin + offset, angle, _sum_delta, _bullet_count 
		)
				
		_bullet_count += 1
		if _bullet_count >= bullet_num:
			set_process(false)
			finished.emit()
			return
