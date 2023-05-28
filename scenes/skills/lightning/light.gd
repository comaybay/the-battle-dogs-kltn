extends CharacterBody2D

@export var veloc = Vector2(0,900)
@export var dame = 10
var allCats = {}

func _ready():
	$AnimationPlayer.play("move")

func _physics_process(delta):
	var collision = move_and_collide(veloc * delta)
	
	if collision:
		var character = collision.get_collider()
		var cats = $Area2D.get_overlapping_bodies()
		for cat in cats :
			if allCats.has(cat)  == false:
				cat.take_damage(dame)
				cat.effect_reduce("speed" , 0.5, 5)	
				allCats[cat] = 1
			
		
		if character is Land : # va cham dat			
			print(character)
			die()
		

func die() :
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.2).timeout
	queue_free()
