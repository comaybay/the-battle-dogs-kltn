@tool
extends FSMState

var knockback_countdown: int
var knockback_vel: Vector2

# called when the state is activated
func enter(data: Dictionary) -> void:
	knockback_countdown = 2
	knockback_vel = Vector2(200, -250)
	character.n_AnimationPlayer.play("knockback")

# called when the state is deactivated
func exit() -> void:
	pass 
		
# called every frame when the state is active
func update(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
	else:
		if knockback_countdown > 0:
			character.velocity.x = knockback_vel.x * -character.move_direction
			character.velocity.y = knockback_vel.y
			
			knockback_countdown -= 1
			knockback_vel = Vector2(150, -150)
		else:
			if character.health <= 0:
				transition.emit("DieState")
			else:
				transition.emit("MoveState")
		
	character.move_and_slide() 

# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	
	

