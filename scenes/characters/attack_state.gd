@tool
extends FSMState

var target: Character

# called when the state is activated
func enter(data: Dictionary) -> void:
	target = data.target
	character.n_AnimationPlayer.play("attack") 
	character.n_Sprite2D.frame_changed.connect(on_frame_changed)
	character.n_AnimationPlayer.animation_finished.connect(on_animation_finished)

func on_frame_changed():
	if character.n_Sprite2D.frame == character.attack_frame and target != null:
		target.take_damage(character.damage)
			
func on_animation_finished(name):
	character.n_AttackCooldownTimer.start()
	transition.emit("IdleState")
		
# called when the state is deactivated
func exit() -> void:
	character.n_Sprite2D.frame_changed.disconnect(on_frame_changed) 
	character.n_AnimationPlayer.animation_finished.disconnect(on_animation_finished)
		
# called every frame when the state is active
func update(delta: float) -> void:
	pass
# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	

