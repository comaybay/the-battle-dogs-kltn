@tool
class_name AirUnitCat extends BaseCat

@export var movement_radius: int = 500

## move to new target position if after attack is recharged and there is no target to attack [br]
## if set to false, stay at where they are, will not change target when timeout
var change_target_overtime: bool = true

## fairy cat will move around this position
var target_position: Vector2 

var _raycast_pos_y: float 

func _ready() -> void:
	super._ready()
	
	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
		return
	
	_raycast_pos_y = InBattle.get_battlefield().get_land().global_position.y - RAYCAST_OFFSET_Y

func _physics_process(delta: float) -> void:
	n_RayCast2D.global_position.y = _raycast_pos_y
	var fsm: FSM = get_FSM()
	var state: FSMState = fsm.get_current_state()
		
	if not n_RayCast2D.is_colliding() or state is AirUnitKnockbackState:
		return
		
	
	if state.has_method("interpolate_movement"):
		fsm.change_state("AttackState", { "interpolate_movement_callback": state.interpolate_movement })
	else:
		fsm.change_state("AttackState")
	
	n_RayCast2D.enabled = false
	n_AttackCooldownTimer.start()
	set_physics_process(false)
