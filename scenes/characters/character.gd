@tool
extends CharacterBody2D
class_name Character

enum Type { DOG, ENEMY }

## 0 for dog, 1 for enemy
@export var character_type: int = Type.DOG
@export var speed: int = 120 # toc do di chuyen

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
		attack_cooldown = val
		if n_AttackCooldownTimer:
		# for some reason timer do not take in 0 correctly	
			n_AttackCooldownTimer.wait_time = max(attack_cooldown, 0.01)
		
## check what frame should an attack occurr when playing the attack animation
@export var attack_sprite: Sprite2D = null
@export var attack_frame: int = 12
@export var health: int = 160 # mau
@export var damage: int = 20 # sat thuong
@export var knockbacks: int = 3
@export var sound_danh = "res://resources/sound/danh nhau/Tieng-bup.mp3"

@onready var n_RayCast2D := $RayCast2D as RayCast2D
@onready var n_AnimationPlayer := $AnimationPlayer as AnimationPlayer
@onready var n_Sprite2D := $Sprite2D as Sprite2D
@onready var n_AttackCooldownTimer := $AttackCooldownTimer as Timer

var size_character
@export var scale_character : int = 1
## position where effect for a character should take place 
var effect_global_position: Vector2:
	get: return n_RayCast2D.global_position

## Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_direction: int
var max_health: int
var next_knockback_health: int
var collision_rect: Rect2

func _ready() -> void:
	size_character = $CollisionShape2D.get_shape().size
	# config 
	max_health = health
	next_knockback_health = max_health - (max_health / knockbacks)
	move_direction = (1 if character_type == Type.DOG else -1)
	
	# for some reason timer do not take in 0 correctly
	n_AttackCooldownTimer.wait_time = max(attack_cooldown, 0.01)
	
	n_RayCast2D.target_position.x = attack_range * move_direction
	
	collision_rect = $CollisionShape2D.shape.get_rect()
	n_RayCast2D.position.x = $CollisionShape2D.position.x + collision_rect.position.x
	
	if character_type == Type.DOG:
		n_RayCast2D.position.x += collision_rect.size.x
	
	if custom_attack_area != null:
		custom_attack_area.disable_mode
		
	if not Engine.is_editor_hint():
		$AnimationPlayer.play("move")
		
		## add random sprite offset for better visibility when characters are stacked on eachother
		var rand_y: int = randi_range(-20, 20)
		$Sprite2D.position += Vector2(randi_range(-20, 20), rand_y)
		## render stuff correctly
		z_index = rand_y + 20
	
	if Engine.is_editor_hint():
		property_list_changed.connect(queue_redraw)

## get center point of a character
func get_center_point():
	return $CollisionShape2D.position + (collision_rect.size / 2) 


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
		draw_multiline_string(default_font, Vector2(0, $Sprite2D.position.y - (character_size.y / 2) - 50), debug_string, HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

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
	
	if _is_pass_knockback_health():
		if health > 0:
			while _is_pass_knockback_health():
				next_knockback_health = max(0, next_knockback_health - (max_health / knockbacks))
			knockback()
		else:
			knockback(1.25) 
		

func effect_reduce(effect : String , number : float  = 1, time : float = 0) -> void: # gay anh huong trong time
	if effect == "speed" :
		speed = speed * number 
	elif effect ==  "damage" :
		damage = damage * number
	elif effect ==  "attack_cooldown" :
		attack_cooldown = attack_cooldown / number
	elif effect ==  "attack_area_range" :
		attack_area_range = attack_area_range * number
	elif effect ==  "health" :
		health = health * number
	
	await get_tree().create_timer(time).timeout
	
	if effect == "speed" :
		speed = speed / number 
	elif effect ==  "damage" :
		damage = damage / number
	elif effect ==  "attack_cooldown" :
		attack_cooldown = attack_cooldown * number
	elif effect ==  "attack_area_range" :
		attack_area_range = attack_area_range / number
	elif effect ==  "health" :
		health = health / number
	

func _is_pass_knockback_health():
	return health <= next_knockback_health
	

func powerUp(types , number : float, time : float) :
	for type in types :
		if (type == "attack_cooldown"):
			attack_cooldown = attack_cooldown / number
		if (type == "health"):
			health = health * number
		if (type == "damage") :
			damage = damage * number
		if (type == "speed") :
			speed = speed * number
	await get_tree().create_timer(time).timeout
	for type in types :
		if (type == "attack_cooldown"):
			attack_cooldown = attack_cooldown * number
		if (type == "health"):
			health = health / number
		if (type == "damage") :
			damage = damage / number
		if (type == "speed") :
			speed = speed / number

func knockback(scale: float = 1):
	$FiniteStateMachine.change_state("KnockbackState", {"scale": scale})	
	
func kill():
	$FiniteStateMachine.change_state("DieState")	

