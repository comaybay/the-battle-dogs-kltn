class_name AirUnitMoveState extends FSMState

@onready var cat: AirUnitCat = owner
@onready var curve: Curve2D = %Path2D.curve

var _passed_delta: float
var _duration: float
var _initial_multiplier: float

func enter(data: Dictionary) -> void:
	_passed_delta = 0
	
	cat.n_AnimationPlayer.play("move")
	%Path2D.global_position = cat.global_position
	
	var random_offset := Vector2(cat.movement_radius, 0).rotated(PI * 2 * randf())
	var dest_pos = cat.target_position + random_offset	 
	dest_pos -= cat.global_position
	
	var up_length := randf_range(dest_pos.length() * 0.1, dest_pos.length() * 0.3)
	
	var offset_angle = (PI * 0.5) * Global.rand_sign()
	var mid_pos = dest_pos * 0.5 + Vector2(up_length, 0).rotated(dest_pos.angle() + offset_angle)
	
	## ensure fairy cat doesn't turn around mid way (move forwards only)
	if sign(mid_pos.x) != sign(dest_pos.x - mid_pos.x):
		mid_pos = dest_pos * 0.5 + Vector2(up_length, 0).rotated(dest_pos.angle() - offset_angle)
	
	curve.set_point_position(0, Vector2.ZERO)
	curve.set_point_position(1, mid_pos)
	curve.set_point_position(2, dest_pos)
	
	curve.set_point_in(1, Vector2(up_length, 0).rotated(dest_pos.angle() + PI))
	curve.set_point_out(1, Vector2(up_length, 0).rotated(dest_pos.angle()))
	
	_duration = curve.get_baked_length() / cat.speed
	_initial_multiplier = cat.get_multiplier(Character.MultiplierTypes.SPEED)
	
func update(delta: float) -> void:
	%PathFollow2D.progress_ratio = interpolate_movement(delta)
	
	var new_scale_x: int = sign(cat.global_position.x - %PathFollow2D.global_position.x)
	if new_scale_x != 0:
		cat.get_character_animation_node().scale.x = new_scale_x
		
	cat.global_position = %PathFollow2D.global_position 
	
	if is_equal_approx(%PathFollow2D.progress_ratio, 1.0):
		transition.emit("IdleState")	

func interpolate_movement(delta: float) -> float:
	## cases where the fairy cat's movement speed changes mid way due to being manipulated by external forces e.g: player skills 
	_passed_delta += delta * (cat.get_multiplier(Character.MultiplierTypes.SPEED) / _initial_multiplier)
	return Tween.interpolate_value(0.0, 1.0, min(_passed_delta, _duration), _duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
