@tool
extends FSMState

# called when the state is activated
func enter(data: Dictionary):
	pass 

# (optional) called when the state is deactivated
func exit():
	pass 
		
# (optional) equivalent to _process but only called when the state is active
func update(delta):
	pass 
	
# (optional) equivalent to _physics_process but only called when the state is active
func physics_update(delta):
	pass 

# (optional) equivalent of _input but only called when the state is active
func input(event: InputEvent):
	pass 
	
	

