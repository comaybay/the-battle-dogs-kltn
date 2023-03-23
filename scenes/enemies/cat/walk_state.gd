@tool
extends FSMState

@onready var cat: Cat = owner

# called when the state is activated
func enter(data: Dictionary) -> void:
	cat.get_node("AnimationPlayer").play("walk")
	cat.n_RayCast2D.target_position = Vector2(-cat.attack_range, 0)

# called when the state is deactivated
func exit() -> void:
	pass 
		
# called every frame when the state is active
func update(delta: float) -> void:
	if not cat.is_on_floor():
		cat.velocity.y += cat.gravity * delta

	var collider: CharacterBody2D = cat.n_RayCast2D.get_collider()
	if collider == null:
		cat.velocity.x = -cat.speed
		
	else:
		if cat.n_AnimationPlayer.current_animation != "attack":
			cat.velocity = Vector2.ZERO
			var dog_shape: CollisionShape2D = collider.get_node("CollisionShape2D")
			var dog_rect = dog_shape.shape.get_rect() 
#			cat.position.x = collider.position.x + (dog_rect.size.x / 2) + cat.attack_range
			
			if cat.n_AttackCooldownTimer.is_stopped():
				transition.emit("AttackState", { "target": collider })
			else:
				transition.emit("IdleState")
		
	cat.move_and_slide() 

# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	
