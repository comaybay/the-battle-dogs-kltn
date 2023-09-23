extends CharacterBody2D

const HitFx := preload("res://scenes/effects/hit_fx/hit_fx.tscn")

@export var veloc = Vector2(300,600)	
@export var dame = 100
var count = 0
func _ready():
	var fire_ball_upgrade = Data.skills.get('fire_ball')
	if fire_ball_upgrade != null:
		dame = dame + (dame * 0.5 * (fire_ball_upgrade['level'] - 1))

func _physics_process(delta):
	var collision = move_and_collide(veloc * delta)
	if collision:		
		#veloc = veloc.bounce(collision.get_normal())  # phan xa lai khi cham
		var character = collision.get_collider()
		if character: # va cham all	
			die()
			if (character is BaseCat) and (count == 0) : # va cham BaseCat (all cat)				
				count += 1
				character.take_damage(dame)	
				_create_attack_fx(character.effect_global_position)
func die() :
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.7, false).timeout
	queue_free()

func _create_attack_fx(global_position: Vector2):	
	var hit_fx: HitFx = HitFx.instantiate()
	get_tree().current_scene.get_node("EffectSpace").add_child(hit_fx)
	hit_fx.global_position = global_position
