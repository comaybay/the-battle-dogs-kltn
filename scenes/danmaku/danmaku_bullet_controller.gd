class_name DanmakuBulletController extends RefCounted

signal body_enter(body: Node2D)

var _native_bullet_id
var _bullet: DanmakuBulletKit
var _danmaku_space: DanmakuSpace

var character_type: Character.Type

var damage: int:
	get: return _bullet.damage
	set(value): _bullet.damage = value

var position: Vector2:
	get: return Bullets.get_bullet_property(_native_bullet_id, "transform").origin
	set(value): 
		if is_bullet_valid(): 
			var transform: Transform2D = Bullets.get_bullet_property(_native_bullet_id, "transform")
			transform.origin = value
			Bullets.set_bullet_property(_native_bullet_id, "transform", transform)
		
var rotation: 
	get: return Bullets.get_bullet_property(_native_bullet_id, "transform").rotation
	set(value): 
		if is_bullet_valid(): 
			var transform: Transform2D = Bullets.get_bullet_property(_native_bullet_id, "transform")
			Bullets.set_bullet_property(
				_native_bullet_id, "transform", Transform2D(value, transform.origin)
			)
		
var velocity: Vector2:
	get: return Bullets.get_bullet_property(_native_bullet_id, "velocity")
	set(value): 
		if is_bullet_valid(): 
			Bullets.set_bullet_property(_native_bullet_id, "velocity", value)

## degrees per second
var rotation_speed: float:
	get: return rad_to_deg(Bullets.get_bullet_property(_native_bullet_id, "rotation_speed"))
	set(value):
		if is_bullet_valid(): 
			Bullets.set_bullet_property(_native_bullet_id, "rotation_speed", deg_to_rad(value))
	
func setup(bullet: DanmakuBulletKit, native_bullet_id, character_type: Character.Type) -> void:
	_bullet = bullet
	_native_bullet_id = native_bullet_id
	self.character_type = character_type
	
	Bullets.set_bullet_property(_native_bullet_id, "data", self)
	body_enter.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	if body is Character:
		body.take_damage(damage)
		InBattle.add_hit_effect(position)
		AudioPlayer.play_in_battle_sfx(_bullet.hit_sfx)
		Bullets.call_deferred("release_bullet", _native_bullet_id)

func is_bullet_valid() -> bool:
	return Bullets.is_bullet_valid(_native_bullet_id)
	
## start controlling the bullet if bullet is valid
func start(callable: Callable) -> void:
	if is_bullet_valid():
		await callable.call()
		
func physic_process(delta: float) -> void:
	Bullets.physics_process_bullet(_native_bullet_id, delta)
