@tool
class_name FairyCat extends AirUnitCat

var _floating_offset: float
var _wing_flap_tween: Tween

func _ready() -> void:
	super._ready()
	
	if Engine.is_editor_hint():
		set_physics_process(false)
		return
	
	_wing_flap_tween = _create_wing_flap_tween()

	n_AttackCooldownTimer.timeout.connect(func(): 
		n_RayCast2D.enabled = true
		n_RayCast2D.global_position.y = _raycast_pos_y
		set_physics_process(true)
	)
	
	get_FSM().state_entering.connect(_on_state_entering)

func _on_state_entering(state_name: String, _data: Dictionary) -> void:
	if state_name == "KnockbackState" or (state_name == "IdleState" and _data.has("knockedback")):
		_wing_flap_tween.pause()
	else:
		_wing_flap_tween.play()	

func _create_wing_flap_tween() -> Tween:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_loops().set_parallel()
	var nodes := [$CharacterAnimation, $DanmakuHitbox, $CollisionShape2D]
	
	for node in nodes: 
		tween.tween_property(node, "position:y", 20.0, 0.2).as_relative()

	tween.chain()
	for node in nodes: 
		tween.tween_property(node, "position:y", -20.0, 0.2).as_relative()
	
	tween.custom_step(randf_range(0, 0.4))
	return tween
