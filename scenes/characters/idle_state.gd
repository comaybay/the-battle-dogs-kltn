@tool
extends FSMState

@onready var character: Character = owner

# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.n_AnimationPlayer.play("idle")
	
	if character.n_AttackCooldownTimer.is_stopped():
		transition.emit("MoveState")
	else:
		character.n_AttackCooldownTimer.timeout.connect(on_timeout)
		
		
func on_timeout() -> void:
	var collider = character.n_RayCast2D.get_collider() 
	if collider != null and not InBattle.in_request_mode:
		transition.emit("AttackState", {'target': collider })
	else:
		transition.emit("MoveState")

# called when the state is deactivated
func exit() -> void:
	character.n_AttackCooldownTimer.timeout.disconnect(on_timeout) 
		
# called every frame when the state is active
func update(_delta: float) -> void:
	if character.n_RayCast2D.get_collider() == null:
		transition.emit("MoveState")
