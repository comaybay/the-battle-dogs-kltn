class_name Bullet extends Area2D

var _velocity: Vector2 = Vector2.ZERO
var _rotation: float = 0
var _rotation_duration: float = 0
var _damage: int

enum OfudaColor { RED, GRAY }

const OUTSIDE_MARGIN: int = 1000
var _limit_left: int = -OUTSIDE_MARGIN
var _limit_right: int
var _limit_top: int
var _limit_bottom: int = OUTSIDE_MARGIN

func set_rotation_speed(degree_per_sec: float, duration: float = -1) -> void:
	_rotation_duration = duration
	_rotation = deg_to_rad(degree_per_sec) 

func _physics_process(delta: float) -> void:
	rotation = _velocity.angle()
	position += _velocity * delta
	
	if position.x < _limit_left or _limit_right < position.x or position.y < _limit_top or _limit_bottom < position.y:
		queue_free() 

	if is_equal_approx(_rotation_duration, -1) or _rotation_duration > 0:
		_velocity = _velocity.rotated(_rotation * delta)
	
	if _rotation_duration > 0:
		_rotation_duration = max(_rotation_duration - delta, 0) 
