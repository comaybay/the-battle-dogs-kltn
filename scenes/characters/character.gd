@tool
extends CharacterBody2D
class_name Character

enum Type { DOG, ENEMY }

## 0 for dog, 1 for enemy
@export var character_type: int = Type.DOG
@export var speed: int = 100
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
@export var attack_cooldown: int = 2

## check what frame should an attack occurr when playing the attack animation
@export var attack_frame: int = 12
@export var health: int = 250
@export var damage: int = 20
@export var knockbacks: int = 3

@onready var n_RayCast2D := $RayCast2D as RayCast2D
@onready var n_AnimationPlayer := $AnimationPlayer as AnimationPlayer
@onready var n_Sprite2D := $Sprite2D as Sprite2D
@onready var n_AttackCooldownTimer := $AttackCooldownTimer as Timer

## Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_direction: int
var max_health: int
var next_knockback_health: int
var collision_rect: Rect2

func _ready() -> void:
	$AnimationPlayer.play("move")
	
	# config 
	max_health = health
	next_knockback_health = max_health - (max_health / knockbacks)
	move_direction = (1 if character_type == Type.DOG else -1)
	
	n_AttackCooldownTimer.wait_time = attack_cooldown
	n_RayCast2D.target_position.x = attack_range * move_direction
	
	collision_rect = $CollisionShape2D.shape.get_rect()
	n_RayCast2D.position.x = $CollisionShape2D.position.x + collision_rect.position.x
	if character_type == Type.DOG:
		n_RayCast2D.position.x += collision_rect.size.x
	
	if Engine.is_editor_hint():
		property_list_changed.connect(queue_redraw)

func _draw() -> void:
	if Engine.is_editor_hint() or Debug.is_debug_mode():
		var attack_point = n_RayCast2D.position + Vector2(attack_range * move_direction, 0)
		draw_dashed_line(n_RayCast2D.position, attack_point, Color.YELLOW, 5, 10)	
		
		var is_single_target := attack_area_range <= 0
		var half_attack_range_vec := Vector2(3, 0) if is_single_target else Vector2(attack_area_range / 2.0, 0) 
		var down_vec = Vector2(0, 10)
		var attack_area_color := Color.DEEP_SKY_BLUE if is_single_target else Color.LAWN_GREEN
		draw_line(attack_point - half_attack_range_vec + down_vec, attack_point + half_attack_range_vec + down_vec, attack_area_color, 5)		
		
		var default_font := ThemeDB.fallback_font
		var default_font_size := 42
		var debug_string := "Attack type: %s" % ("single target" if is_single_target else "area attack") + "\n%s/%s" % [health, max_health] 
		var character_size := n_Sprite2D.get_rect().size
		draw_multiline_string(default_font, Vector2(0, -character_size.y / 2 - 50), debug_string, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

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
	health -= ammount
	
	if Debug.is_debug_mode():
		queue_redraw()
	
	if health <= next_knockback_health:
		next_knockback_health = max(0, next_knockback_health - (max_health / knockbacks))
		$FiniteStateMachine.change_state("KnockbackState")	
		
func kill():
	$FiniteStateMachine.change_state("DieState")	

