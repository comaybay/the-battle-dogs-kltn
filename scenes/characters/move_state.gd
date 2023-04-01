@tool
extends FSMState

# called when the state is activated
func enter(data: Dictionary) -> void:
	character.get_node("AnimationPlayer").play("move")

# called when the state is deactivated
func exit() -> void:
	pass 
		
# called every frame when the state is active
func update(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta

	var collider: CharacterBody2D = character.n_RayCast2D.get_collider()
	if collider == null:
		character.velocity.x = character.speed * character.move_direction
		
	else:
		if character.n_AnimationPlayer.current_animation != "attack":
			character.velocity = Vector2.ZERO
			var dog_shape: CollisionShape2D = collider.get_node("CollisionShape2D")
			var dog_rect = dog_shape.shape.get_rect() 
#			character.position.x = collider.position.x + (dog_rect.size.x / 2) + character.attack_range

			if character.n_AttackCooldownTimer.is_stopped():
				transition.emit("AttackState", { "target": collider })
			else:
				transition.emit("IdleState")
		
	character.move_and_slide() 

# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	
