class_name Ofuda extends Area2D

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

func setup(global_position: Vector2, velocity: Vector2, damage: int, color: OfudaColor, character_type: Character.Type):
	var battlefield := InBattle.get_battlefield() as BaseBattlefield
	_limit_right = battlefield.get_stage_width() + BaseBattlefield.TOWER_MARGIN * 2 + OUTSIDE_MARGIN
	_limit_top = -(battlefield.get_stage_height() + OUTSIDE_MARGIN)
	
	body_entered.connect(_on_body_entered)
	_velocity = velocity
	_damage = damage
	self.global_position = global_position
	
	if character_type == Character.Type.CAT:
		self.scale.x = -self.scale.x
		collision_mask = 0b10

	$Sprite2D.frame = 0 if color == OfudaColor.RED else 1

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
	
func _on_body_entered(body: Node2D) -> void:	
	InBattle.add_hit_effect(global_position)
	AudioPlayer.play_in_battle_sfx(MikoDog.HIT_SFX)
	queue_free()
	
	if not InBattle.in_request_mode and body is Character:
		body.take_damage(_damage)
		
