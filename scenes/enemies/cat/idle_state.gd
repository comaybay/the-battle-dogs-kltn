@tool
extends FSMState
@onready var cat: Cat = owner

# called when the state is activated
func enter(data: Dictionary) -> void:
	cat.n_AnimationPlayer.play("idle")
	
	if cat.n_AttackCooldownTimer.is_stopped():
		transition.emit("WalkState")
	else:
		cat.n_AttackCooldownTimer.timeout.connect(on_timeout)
		
		
func on_timeout() -> void:
	transition.emit("WalkState")

# called when the state is deactivated
func exit() -> void:
	cat.n_AttackCooldownTimer.timeout.disconnect(on_timeout) 
		
# called every frame when the state is active
func update(delta: float) -> void:
	pass 

# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	
	

