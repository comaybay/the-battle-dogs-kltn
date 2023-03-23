@tool
extends FSMState

@onready var cat: Cat = owner

var target: Node2D

# called when the state is activated
func enter(data: Dictionary) -> void:
	target = data.target
	cat.n_AnimationPlayer.play("attack") 
	cat.n_Sprite2D.frame_changed.connect(on_frame_changed)
	cat.n_AnimationPlayer.animation_finished.connect(on_animation_finished)

func on_frame_changed():
	if cat.n_Sprite2D.frame == 12:
		target.position.x -= 200
			
func on_animation_finished(name):
	cat.n_AttackCooldownTimer.start()
	transition.emit("IdleState")
		
# called when the state is deactivated
func exit() -> void:
	cat.n_Sprite2D.frame_changed.disconnect(on_frame_changed) 
	cat.n_AnimationPlayer.animation_finished.disconnect(on_animation_finished)
		
# called every frame when the state is active
func update(delta: float) -> void:
	pass
# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	

