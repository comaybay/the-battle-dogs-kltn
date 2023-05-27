extends CharacterBody2D

@export var veloc = Vector2(300,600)
@export var dame = 50
var count = 0
func _ready():
	$AnimationPlayer.play("move")

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
			
		

func die() :
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.7).timeout
	queue_free()
