extends CharacterBody2D

const SPEED_Y: int = 8000
const BASE_DAMAGE: int = 10
const BASE_MULTIPLIER: float = 0.9
const BASE_DURATION: float = 2

var _has_affected = {}
var _damage: int
var _multiplier: float
var _duration: float

var _sync_data: Dictionary

func _ready() -> void:
	set_physics_process(false)

func setup(global_position: Vector2, skill_user: Character.Type):
	_sync_data = {
		"object_type": P2PObjectSync.ObjectType.SKILL,
		"scene": "res://scenes/skills/lightning/light.tscn",
		"instance_id": get_instance_id(),
		"skill_user": skill_user
	}
	add_to_group(P2PObjectSync.SYNC_GROUP)
	
	self.global_position = global_position
	velocity.y = SPEED_Y
	
	if skill_user == Character.Type.CAT:
		$CharacterDetector.set_collision_mask_value(3, false)
		$CharacterDetector.set_collision_mask_value(2, true)
	
	var level = InBattle.get_skill_level('lightning', skill_user)
	_damage = BASE_DAMAGE * 0.1 * level
	_multiplier = max(BASE_MULTIPLIER - level * 0.07, 0.05)
	_duration = BASE_DURATION + level * 0.3
	
	$CharacterDetector.body_entered.connect(_on_enemy_entered)
	set_physics_process(true)

func _physics_process(delta):
	var collsion := move_and_collide(velocity * delta)
	if collsion:
		die()

func _on_enemy_entered(enemy: Character):
	if _has_affected.has(enemy):
		return
		
	_has_affected[enemy] = true
	
	var distance := enemy.global_position.distance_to(global_position) / 2
	var position := enemy.global_position.move_toward(global_position, distance)
	InBattle.add_hit_effect(position)
		
	if not InBattle.in_request_mode:
		enemy.take_damage(_damage)
		enemy.set_multiplier(Character.MultiplierTypes.ATTACK_SPEED, _multiplier)	
		enemy.set_multiplier(Character.MultiplierTypes.SPEED, _multiplier)	
		
		get_tree().create_timer(_duration, false).timeout.connect(
			func(): enemy.reset_multipliers(),
			CONNECT_ONE_SHOT
		)
	
func die():
	set_physics_process(false)
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()
	
func get_p2p_sync_data() -> Dictionary:
	remove_from_group(P2PObjectSync.SYNC_GROUP)
	_sync_data['position'] = global_position
	return _sync_data
	
func p2p_setup(sync_data: Dictionary) -> void:
	setup(sync_data['position'], sync_data['skill_user'])

func p2p_sync(sync_data: Dictionary) -> void:
	global_position = sync_data['position'] 
	
func p2p_remove() -> void:
	pass
