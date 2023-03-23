@tool
extends FSMState

# called when the state is activated
func enter(data: Dictionary) -> void:
	pass 

# called when the state is deactivated
func exit() -> void:
	pass 
		
# called every frame when the state is active
func update(delta: float) -> void:
	pass 

# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	
	
