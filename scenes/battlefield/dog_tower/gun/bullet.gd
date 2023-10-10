extends CharacterBody2D

@export var dame = 5
var count = 0
var object
var speed = 500
var _stop_following: bool = false
var _direction: Vector2 = Vector2(0.5, 0.5) 
var _target: BaseCat

const HitFx := preload("res://scenes/effects/hit_fx/hit_fx.tscn")
func _ready():
	var bullet_upgrade = Data.passives.get("gun_tower")
	if bullet_upgrade != null:
		dame = dame + (dame * (bullet_upgrade['level']))		
		
func setup(global_position: Vector2, target: BaseCat) :
	_target = target  
	self.global_position = global_position 
	_calculate_direction()
	
	# Khong thay doi vi tri vien dan nua neu meo da chet hoac dang bi vap nga
	target.tree_exiting.connect(func(): _stop_following = true, CONNECT_ONE_SHOT)
	target.knockbacked.connect(func(): _stop_following = true, CONNECT_ONE_SHOT)

func _calculate_direction():
	_direction = (_target.global_position - global_position).normalized()
	
func _physics_process(delta):
	if not _stop_following:
		_calculate_direction()
	
	var collision = move_and_collide(_direction * speed * delta)
	if collision:
		var character = collision.get_collider()
		if character: # va cham all			
			if (character is BaseCat) and (count == 0) : # va cham BaseCat (all cat)
				count += 1
				character.take_damage(dame)
				queue_free()
		
		var hit_fx: HitFx = HitFx.instantiate()
		get_tree().current_scene.get_node("EffectSpace").add_child(hit_fx)
		hit_fx.global_position = global_position
		queue_free()
