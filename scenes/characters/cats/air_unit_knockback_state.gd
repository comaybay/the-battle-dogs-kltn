class_name AirUnitKnockbackState extends CharacterKnockbackState

func enter(data: Dictionary) -> void:
	knockback_vel = Vector2(200, -450) * data['scale']
	if character.health <= 0:
		knockback_vel = Vector2(400, -800)
	
	character.n_AnimationPlayer.play("knockback")
		
	character.velocity.x = knockback_vel.x * -character.move_direction
	character.velocity.y = knockback_vel.y
	knockback_countdown = 1

# called when the state is deactivated
func exit() -> void:
	character.n_DanmakuHitbox.set_deferred("monitoring", true)
	if character.character_type == Character.Type.DOG:
		character.set_collision_layer_value(2, true)
	else: 
		character.set_collision_layer_value(3, true) 
		
# called every frame when the state is active
func physics_update(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity.y += character.gravity * delta
		
		if character.health <= 0 and character.velocity.y >= 300:
			transition.emit("DieState")
			return
		
		character.move_and_slide() 
		return
	
	var _prev_velocity = character.velocity
	if knockback_countdown > 0:
		character.velocity.x = knockback_vel.x * -character.move_direction
		character.velocity.y = knockback_vel.y
		
		var collision := character.get_slide_collision(0)
		var remainder_delta: float = collision.get_remainder().x / _prev_velocity.x
		character.velocity.y += character.gravity * remainder_delta
		
		knockback_countdown -= 1
		knockback_vel = knockback_vel * 0.75
		character.move_and_slide() 
	else:
		if character is BaseDog and character.is_user_control == true:
			transition.emit("UserMoveState")
		else: 
			transition.emit("IdleState", { "wait_time": 2.0, "knockedback": true })
			
