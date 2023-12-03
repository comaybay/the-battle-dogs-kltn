@tool
extends CharacterBody2D
class_name Character

signal knockbacked
signal zero_health

enum Type { DOG, CAT }

## Multiplier will affect the character's resulting output (such as damage inflicted, movement speed, etc) 
enum MultiplierTypes { DAMAGE, DAMAGE_TAKEN, SPEED, ATTACK_SPEED }
## Set Multiplier behaviours
enum SetBehaviour { OVERWRITE, TAKE_HIGHER, TAKE_LOWER}
var _multipliers: Dictionary = {
	MultiplierTypes.DAMAGE: 1.0,
	MultiplierTypes.DAMAGE_TAKEN: 1.0,
	MultiplierTypes.SPEED: 1.0,
	MultiplierTypes.ATTACK_SPEED: 1.0
}

## 0 for dog, 1 for cat
@export var character_type: Type = Type.DOG:
	set(val):
		character_type = val
		notify_property_list_changed()  
		queue_redraw()
		
@export var speed: int = 120:
	get: return speed * _multipliers[MultiplierTypes.SPEED]

## if not null, will be use for attack collision detection
## and will ignore the "attack range" and "attack area range" properties when attacking
## (attack range is still used for detecting when to stop moving)
@export var custom_attack_area: Area2D = null:
	set(val):
		custom_attack_area = val
		notify_property_list_changed()  
		queue_redraw()
		
@export var attack_range: int = 40:
	set(val):
		attack_range = val
		notify_property_list_changed()  
		queue_redraw()

## 0 for single target
@export var attack_area_range: int = 0: 
	set(val):
		attack_area_range = val
		notify_property_list_changed()  
		queue_redraw()
		
## in seconds
@export var attack_cooldown: float = 2: # toc do danh
	set(val):
		attack_cooldown = max(val, 0.05)
		if n_AttackCooldownTimer:
		# for some reason timer do not take in 0 correctly	
			n_AttackCooldownTimer.wait_time = attack_cooldown
		
## check what frame should an attack occurr when playing the attack animation
@export var attack_sprite: Sprite2D = null
@export var attack_frame: int = 12
@export var health: int = 160 

@export var damage: int = 20:
	get: return int(damage * _multipliers[MultiplierTypes.DAMAGE])
	
@export var knockbacks: int = 3

const DEFAULT_ATTACK_SFX = preload("res://resources/sound/battlefield/bite.mp3")
const DEFAULT_DIE_SFX = preload("res://resources/sound/battlefield/death.mp3")
@export var attack_sfx: AudioStream = DEFAULT_ATTACK_SFX 
@export var die_sfx: AudioStream = DEFAULT_DIE_SFX
	
@onready var n_RayCast2D := $RayCast2D as RayCast2D
@onready var n_AnimationPlayer := $AnimationPlayer as AnimationPlayer
@onready var n_Sprite2D := $CharacterAnimation/Character as Sprite2D
@onready var n_AttackCooldownTimer := $AttackCooldownTimer as Timer
@onready var n_DanmakuHitbox := %DanmakuHitbox as Area2D

func get_character_animation_node() -> Node2D:
	return $CharacterAnimation

## A general position where effect for a character should take place (example: hit effect). 
## Use this when unsure where the effect should be at
func get_effect_global_position() -> Vector2:
	return n_RayCast2D.global_position

## Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_direction: int
var max_health: int
var next_knockback_health: int
var collision_rect: Rect2
var _is_boss: bool
func is_boss() -> bool: return _is_boss

func _validate_property(property: Dictionary):
	if property.name in ["attack_sprite", "attack_frame"] and custom_attack_area != null:
		property.usage = PROPERTY_USAGE_NO_EDITOR

## this setup func is used internally by it's subcalsses
func _setup(global_position: Vector2, is_boss: bool) -> void:
	self.global_position = global_position
	
	_is_boss = is_boss
	if is_boss:
		add_to_group("bosses")
		
	await ready
	self.global_position.y += global_position.y - get_bottom_global_position().y

func _init() -> void:
	if Engine.is_editor_hint():
		return
		
	if not AudioPlayer.has_in_battle_sfx(attack_sfx):
		AudioPlayer.add_in_battle_sfx(attack_sfx, 20)
	
	if not AudioPlayer.has_in_battle_sfx(die_sfx):
		AudioPlayer.add_in_battle_sfx(die_sfx, 20)
	
		# hide away the character until everything is setup
		position.y = 999999 

func _ready() -> void:
	if not Engine.is_editor_hint():
		## add random sprite offset for better visibility when characters are stacked on eachother
		var rand_y: int = randi_range(-20, 20)
		$CharacterAnimation.position += Vector2(randi_range(-20, 20), rand_y)
		## render stuff correctly
		z_index = rand_y + 20
		
		_update_character()
		
		# danmaku shape is the same as collision shape
		var danmaku_shape := %DanmakuHitbox/CollisionShape2D
		danmaku_shape.shape.size = $CollisionShape2D.shape.size
		danmaku_shape.position = $CollisionShape2D.position
		%DanmakuHitbox.area_shape_entered.connect(_on_danmaku_bullet_entered)
		
		
	if Engine.is_editor_hint():
		max_health = health
		property_list_changed.connect(
			func():
				_update_character()
				queue_redraw()
		)
		
func _update_character():
	# config 
	max_health = health
	next_knockback_health = max_health - (max_health / knockbacks)
	move_direction = (1 if character_type == Type.DOG else -1)
		
	# for some reason timer do not take in 0 correctly
	$AttackCooldownTimer.wait_time = attack_cooldown
	
	$RayCast2D.target_position.x = attack_range * move_direction
	
	collision_rect = $CollisionShape2D.shape.get_rect()
	n_RayCast2D.position.x = $CollisionShape2D.position.x + collision_rect.position.x
	n_RayCast2D.position.y = $CollisionShape2D.position.y + (collision_rect.size.y / 2) - 25
	
	if character_type == Type.DOG:
		remove_from_group("cats")	
		add_to_group("dogs")	
	
		n_RayCast2D.position.x += collision_rect.size.x
		n_RayCast2D.collision_mask = 0b010100
		self.collision_mask = 0b010001
		self.collision_layer = 0b010
	else:
		remove_from_group("dogs")	
		add_to_group("cats")	
	
		n_RayCast2D.collision_mask = 0b100010
		self.collision_mask = 0b100001
		self.collision_layer = 0b100
	
## get global position of the character's bottom
func get_bottom_global_position() -> Vector2:
	return Vector2(
		$CollisionShape2D.global_position.x, 
		$CollisionShape2D.global_position.y + (collision_rect.size.y / 2)
	)
	
## get center position of the character's bottom
func get_center_global_position() -> Vector2:
	return $CollisionShape2D.global_position
	
func get_center_position() -> Vector2:
	return $CollisionShape2D.position
	
func _draw() -> void:
	if Engine.is_editor_hint() or Debug.is_draw_debug():
		# draw attack range at the feet of the character
		var c_shape_bottom = (collision_rect.size.y / 2) + $CollisionShape2D.position.y
		var start_point = Vector2(n_RayCast2D.position.x, c_shape_bottom)
		var attack_point = Vector2(n_RayCast2D.position.x + attack_range * move_direction, c_shape_bottom)
		draw_dashed_line(start_point, attack_point, Color.YELLOW, 5, 10)	
		
		var is_single_target := attack_area_range <= 0
		var half_attack_range_vec := Vector2(3, 0) if is_single_target else Vector2(attack_area_range / 2.0, 0) 
		var down_vec = Vector2(0, 10)
		var attack_area_color := Color.DEEP_SKY_BLUE if is_single_target else Color.LAWN_GREEN
		draw_line(attack_point - half_attack_range_vec + down_vec, attack_point + half_attack_range_vec + down_vec, attack_area_color, 5)		
		
		var default_font := ThemeDB.fallback_font
		var default_font_size := 42
		var debug_string := "Attack type: %s" % ("single target" if is_single_target else "area attack") + "\n%s/%s" % [health, max_health] 
		var character_size := n_Sprite2D.get_rect().size
		draw_multiline_string(default_font, Vector2(0, n_Sprite2D.position.y - (character_size.y / 2) - 50), debug_string, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

	if not Engine.is_editor_hint() and Debug.is_draw_debug():
		var rect: Rect2 = $CollisionShape2D.shape.get_rect()
		rect.position += $CollisionShape2D.position
		draw_rect(rect, Color.RED, false)

func take_damage(ammount: int) -> void:
	health -= ammount * _multipliers[MultiplierTypes.DAMAGE_TAKEN]
	if is_past_knockback_health():
		if health > 0:
			update_next_knockback_health()
		else:
			zero_health.emit()
		
		n_AttackCooldownTimer.stop()	
		knockback()
	
	if Debug.is_debug_mode():
		queue_redraw()

## Set multiplier for a property [/br]
## This can be use to increase/decrease dog power such as damage, speed, etc. [/br]
## multiplier: this multipler will affect the base value of the character,
## set to 1 to reset property value back to normal 
func set_multiplier(type: MultiplierTypes, multiplier: float, behaviour: SetBehaviour) -> void:
	if (
		(behaviour == SetBehaviour.TAKE_HIGHER and multiplier < _multipliers[type])
		or (behaviour == SetBehaviour.TAKE_LOWER and multiplier > _multipliers[type])
	): return
	
	if type == MultiplierTypes.ATTACK_SPEED:
		if name == "RamielCat":
			print("====SET MUKTIPLOER")
			print(n_AttackCooldownTimer.time_left)
			print(multiplier)
			print("====")
		
		if not n_AttackCooldownTimer.is_stopped():
			n_AttackCooldownTimer.start(n_AttackCooldownTimer.time_left * _multipliers[type])
			n_AttackCooldownTimer.start(max(n_AttackCooldownTimer.time_left / multiplier, 0.05))
			_multipliers[type] = multiplier
		
		n_AttackCooldownTimer.wait_time = max(attack_cooldown / multiplier, 0.05)
		$AnimationPlayer.speed_scale = multiplier
		
func reset_multipliers() -> void:
	if name == "RamielCat":
		print(n_AttackCooldownTimer.time_left)

	if not n_AttackCooldownTimer.is_stopped():
		var attack_speed_multiplier: float = _multipliers[MultiplierTypes.ATTACK_SPEED]
		n_AttackCooldownTimer.start(n_AttackCooldownTimer.time_left * attack_speed_multiplier)

	if name == "RamielCat":
		print(n_AttackCooldownTimer.time_left)
		print(n_AttackCooldownTimer.wait_time)
		print("----")


	n_AttackCooldownTimer.wait_time = attack_cooldown
	$AnimationPlayer.speed_scale = 1.0
	
	for type in _multipliers:
		_multipliers[type] = 1.0

func is_past_knockback_health() -> bool:
	return health <= next_knockback_health

func update_next_knockback_health() -> void:	
	while is_past_knockback_health():
		next_knockback_health = max(0, next_knockback_health - (max_health / knockbacks))

func knockback(scale: float = 1):
	if health <= 0:
		# override scale when character is about to die
		scale = max(1.25, scale)
	
	$FiniteStateMachine.change_state("KnockbackState", {"scale": scale})	
	knockbacked.emit()
	
func kill():
	$FiniteStateMachine.change_state("DieState")	

func get_FSM() -> FSM:
	return $FiniteStateMachine

func _on_danmaku_bullet_entered(area_rid: RID, _area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if not Bullets.is_bullet_existing(area_rid, area_shape_index):
		return
		
	var bullet_id = Bullets.get_bullet_from_shape(area_rid, area_shape_index)

	var controller = Bullets.get_bullet_property(bullet_id, "data") as DanmakuBulletController 
	
	if controller.character_type != character_type: 
		controller.body_enter.emit(self)
