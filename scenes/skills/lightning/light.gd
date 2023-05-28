extends CharacterBody2D

@export var veloc = Vector2(0,500)
@export var dame = 50
var count = 0
func _ready():
	$AnimationPlayer.play("move")

func _physics_process(delta):
	var collision = move_and_collide(veloc * delta)
	
	if collision:
		
		var character = collision.get_collider()
		if (character is BaseCat) and (count == 0) : # va cham BaseCat (all cat)				
				count += 1
				character.take_damage(dame)	
		if character is Land : # va cham all			
			print(character)
			die()
		
		
		

func die() :
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.2).timeout
	queue_free()
