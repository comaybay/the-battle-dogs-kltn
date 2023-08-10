extends CharacterBody2D

const HitFx := preload("res://scenes/effects/hit_fx/hit_fx.tscn")

@export var veloc = Vector2(0,900)
@export var dame = 10
@export var slow_scale: float = 0.75
var allCats = {}

func _ready():
	var lightning_upgrade = Data.skills.get('lightning')
	if lightning_upgrade != null:
		dame = dame + (dame * 0.5 * (lightning_upgrade['level'] - 1))
		slow_scale = max(slow_scale - (lightning_upgrade['level'] - 1) * 0.05, 0)

func _physics_process(delta):
	var collision = move_and_collide(veloc * delta)
	if collision:
		var cats = $Area2D.get_overlapping_bodies()
		for cat in cats :
			if allCats.has(cat) == false:
				cat.take_damage(dame)
				_create_attack_fx(cat.effect_global_position)
				cat.effect_reduce("speed" , slow_scale, 4)	
				allCats[cat] = 1
		
		var target = collision.get_collider()
		if target is Land : # va cham dat			
			die()
		
func die() :
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.2).timeout
	queue_free()
	
func _create_attack_fx(global_position: Vector2):	
	var hit_fx: HitFx = HitFx.instantiate()
	get_tree().current_scene.get_node("EffectSpace").add_child(hit_fx)
	hit_fx.global_position = global_position
