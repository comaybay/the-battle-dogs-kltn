extends CharacterBody2D

var _damage = 10000

func setup():
	self.global_position = Vector2(1500, -1000)
	velocity = Vector2(0, 500)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var all_character = get_tree().get_nodes_in_group("characters")
		for charat in all_character:
			charat.kill()
		die()
	

func die():
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.7, false).timeout
	queue_free()

