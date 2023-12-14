class_name AirUnitIdleState extends FSMState

@export var wait_time_min: float = 0.25 
@export var wait_time_max: float = 2.0

@onready var cat: AirUnitCat = owner
var _wait_token: WaitToken
var _tween: Tween

func enter(data: Dictionary) -> void:
	var wait_time: float = data.get("wait_time", randf_range(wait_time_min, wait_time_max))
	if data.has("knockedback"):
		knockedback_struggle_animation()

	_wait_token = Global.wait_cancelable(wait_time) 
	await _wait_token.wait()
	if _wait_token.is_canceled(): return
	
	if cat.change_target_overtime == false or not cat.n_AttackCooldownTimer.is_stopped() or data.has("knockedback"):
		transition.emit("MoveState")
	else:
		# change target position if attack is recharged but no enemies found
		transition.emit("ChangeTargetState", { 'new_target' : true })

func knockedback_struggle_animation() -> void:
	_tween = create_tween()
	_tween.tween_property(cat.n_CharacterAnimation, "position:x", -10, 0.05).as_relative()
	_tween.tween_property(cat.n_CharacterAnimation, "position:x", 20, 0.1).as_relative()
	_tween.tween_property(cat.n_CharacterAnimation, "position:x", -10, 0.05).as_relative()
	_tween.tween_interval(0.5)
	_tween.finished.connect(func():
		_tween.kill()
		_tween = create_tween().set_loops()
		_tween.set_speed_scale(1.5)
		_tween.tween_property(cat.n_CharacterAnimation, "position:x", -10, 0.05).as_relative()
		_tween.tween_property(cat.n_CharacterAnimation, "position:x", 20, 0.1).as_relative()
		_tween.tween_property(cat.n_CharacterAnimation, "position:x", -10, 0.05).as_relative()
	)

func exit() -> void:
	_wait_token.cancel()
	_wait_token = null
	if _tween != null:
		_tween.kill()
