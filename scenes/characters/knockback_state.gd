@tool
extends FSMState

@onready var character: Character = owner
var knockback_countdown: int
var knockback_vel: Vector2

# called when the state is activated
func enter(data: Dictionary) -> void:
	if character.health <= 0:
		if character is BaseCat and character.is_boss:
			$BossKnockback.play()
		else:
			$FallSound.play()

	knockback_countdown = 2
	knockback_vel = Vector2(200, -250) * data['scale']
	character.n_AnimationPlayer.play("knockback")

	if character.character_type == Character.Type.DOG:
		character.set_collision_layer_value(2, false)
	else:
		character.set_collision_layer_value(3, false)

# called when the state is deactivated
func exit() -> void:
	if character.character_type == Character.Type.DOG:
		character.set_collision_layer_value(2, true)
	else: 
		character.set_collision_layer_value(3, true) 
		
# called every frame when the state is active
func physics_update(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
	else:
		if knockback_countdown > 0:
			character.velocity.x = knockback_vel.x * -character.move_direction
			character.velocity.y = knockback_vel.y
			
			knockback_countdown -= 1
			knockback_vel = knockback_vel * 0.75
		else:
			if character.health <= 0:
				transition.emit("DieState")
			else:
				if character is BaseDog and character.is_user_control == true:
					transition.emit("UserMoveState")
				else: 
					transition.emit("MoveState")
		
	character.move_and_slide() 

	

