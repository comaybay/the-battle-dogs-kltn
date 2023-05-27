extends CharacterBody2D

@export var veloc = Vector2(0,1000)
@export var dame = 10
func _ready():
	$AnimationPlayer.play("move")

func _physics_process(delta):
	var collision = move_and_collide(veloc * delta)
	if collision:
		#veloc = veloc.bounce(collision.get_normal())  # phan xa lai khi cham
		var character = collision.get_collider()
		if character: # va cham all
			die()
			if character is BaseCat : # va cham BaseCat (all cat)
				character.take_damage(dame)
				
		

func die() :
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.7).timeout
	queue_free()
