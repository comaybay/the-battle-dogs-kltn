class_name AirUnitAttackState extends FSMState
## Abstract Air unit character attack state, overwrite method to implement the attack 

## this will be called if previous state's movement interpolation is unfinished and needed to be called now
var interpolate_movement_callback: Callable
var continue_prev_movement: bool = false

func enter(data: Dictionary) -> void:
	interpolate_movement_callback = data.get('interpolate_movement_callback', Callable())
	continue_prev_movement = interpolate_movement_callback.is_valid()
		
## overwrite this method to implement the attack 
func update(delta: float) -> void:
	if not continue_prev_movement:
		return
		
	var cat: AirUnitCat = owner
	%PathFollow2D.progress_ratio = interpolate_movement_callback.call(delta)
	
	var new_scale_x: int = sign(cat.global_position.x - %PathFollow2D.global_position.x)
	if new_scale_x != 0:
		cat.get_character_animation_node().scale.x = new_scale_x
		
	cat.global_position = %PathFollow2D.global_position 
	
	if is_equal_approx(%PathFollow2D.progress_ratio, 1.0):
		continue_prev_movement = false
