@tool
extends FSMState

@onready var character: Character = owner

# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.get_node("AnimationPlayer").play("move")
	$DiChuyen.play()

# called when the state is deactivated
func exit() -> void:
	pass 
		
# called every frame when the state is active
func update(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
	
	# kiem tra va cham
	var collider = character.n_RayCast2D.get_collider()
	if collider == null: #ko va cham
		character.velocity.x = character.speed * character.move_direction 
		
	else:# va cham
		if character.n_AnimationPlayer.current_animation != "attack":
			character.velocity = Vector2.ZERO
			
			if character.n_AttackCooldownTimer.is_stopped():
				transition.emit("AttackState", { "target": collider })
			else:
				transition.emit("IdleState")
		
	character.move_and_slide() 
