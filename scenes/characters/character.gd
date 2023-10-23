@tool
extends CharacterBody2D
class_name Character

signal knockbacked
signal zero_health

enum Type { DOG, CAT }

## Multiplier will affect the character's resulting output (such as damage inflicted, movement speed, etc) 
enum MultiplierTypes { DAMAGE, DAMAGE_TAKEN, SPEED, ATTACK_SPEED }
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
@export var custom_attack_area: Area2D = null

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

	
@onready var n_RayCast2D := $RayCast2D as RayCast2D
@onready var n_AnimationPlayer := $AnimationPlayer as AnimationPlayer
@onready var n_Sprite2D := $CharacterAnimation/Character as Sprite2D
@onready var n_AttackCooldownTimer := $AttackCooldownTimer as Timer

func get_character_animation_node() -> Node2D:
	return $CharacterAnimation

## A general position where effect for a character should take place (example: hit effect). 
## Use this when unsure where the effect should be at
var effect_global_position: Vector2:
	get: return n_RayCast2D.global_position

## Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_direction: int
var max_health: int
var next_knockback_health: int
var collision_rect: Rect2

func setup(global_position: Vector2) -> void:
	self.global_position = global_position
	_reready()

func _init() -> void:
	# hide away the character until everything is setup
	position.y = 999999 

func _ready() -> void:
	if not Engine.is_editor_hint():
		## add random sprite offset for better visibility when characters are stacked on eachother
		var rand_y: int = randi_range(-20, 20)
		$CharacterAnimation.position += Vector2(randi_range(-20, 20), rand_y)
		## render stuff correctly
		z_index = rand_y + 20
		_reready()
		
	if Engine.is_editor_hint():
		property_list_changed.connect(
			func():
				_reready()
				queue_redraw()
		)
		
func _reready():
	# config 
	max_health = health
	next_knockback_health = max_health - (max_health / knockbacks)
	move_direction = (1 if character_type == Type.DOG else -1)
	
	# for some reason timer do not take in 0 correctly
	n_AttackCooldownTimer.wait_time = attack_cooldown
	
	n_RayCast2D.target_position.x = attack_range * move_direction
	
	collision_rect = $CollisionShape2D.shape.get_rect()
	n_RayCast2D.position.x = $CollisionShape2D.position.x + collision_rect.position.x
	n_RayCast2D.position.y = $CollisionShape2D.position.y + (collision_rect.size.y / 2) - 25
	
	if character_type == Type.DOG:
		n_RayCast2D.position.x += collision_rect.size.x
		n_RayCast2D.set_collision_mask_value(2, false)
		n_RayCast2D.set_collision_mask_value(6, false)
		n_RayCast2D.set_collision_mask_value(3, true)
		n_RayCast2D.set_collision_mask_value(5, true)
		
		set_collision_mask_value(6, false)
		set_collision_mask_value(5, true)
		
		set_collision_layer_value(2, true)
		set_collision_layer_value(3, false)
	else:
		n_RayCast2D.set_collision_mask_value(2, true)
		n_RayCast2D.set_collision_mask_value(6, true)
		n_RayCast2D.set_collision_mask_value(3, false)
		n_RayCast2D.set_collision_mask_value(5, false)

		set_collision_mask_value(6, true)
		set_collision_mask_value(5, false)
		
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, true)
	
## get global position of the character's bottom
func get_bottom_global_position() -> Vector2:
	return Vector2(
		$CollisionShape2D.global_position.x, 
		$CollisionShape2D.global_position.y + (collision_rect.size.y / 2)
	)
	
## get center position of the character's bottom
func get_center_global_position() -> Vector2:
	return Vector2(
		$CollisionShape2D.global_position.x, 
		$CollisionShape2D.global_position.y
	)
	
func _draw() -> void:
	if Engine.is_editor_hint() or Debug.is_debug_mode():
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

	if not Engine.is_editor_hint() and Debug.is_debug_mode():
		var rect: Rect2 = $CollisionShape2D.shape.get_rect()
		rect.position += $CollisionShape2D.position
		draw_rect(rect, Color.RED, false)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	
	for anim_name in ['idle', 'knockback', 'move', 'attack']:
		if not n_AnimationPlayer.has_animation(anim_name):	
			warnings.append("Character is missing '%s' animation" % anim_name)
				
	if n_Sprite2D.texture == null:
		warnings.append("Sprite2D node requires a sprite sheet, this is used to display the character.")
	
	return warnings
	
func take_damage(ammount: int) -> void:
	health -= ammount * _multipliers[MultiplierTypes.DAMAGE_TAKEN]
	if is_past_knockback_health():
		if health > 0:
			update_next_knockback_health()
		else:
			zero_health.emit()
			
		knockback()
	
	if Debug.is_debug_mode():
		queue_redraw()

## Set multiplier for a property [/br]
## This can be use to increase/decrease dog power such as damage, speed, etc. [/br]
## multiplier: this multipler will affect the base value of the character,
## set to 1 to reset property value back to normal 
func set_multiplier(type: MultiplierTypes, multiplier: float) -> void:
	_multipliers[type] = multiplier
	
	if type == MultiplierTypes.ATTACK_SPEED:
		n_AttackCooldownTimer.wait_time = max(attack_cooldown * multiplier, 0.05)
		$AnimationPlayer.speed_scale = multiplier
		
func reset_multipliers() -> void:
	for type in _multipliers:
		_multipliers[type] = 1.0
		
	n_AttackCooldownTimer.wait_time = attack_cooldown
	$AnimationPlayer.speed_scale = 1.0

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
