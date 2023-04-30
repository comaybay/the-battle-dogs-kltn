@tool
extends FSMState

# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.queue_free() 

	

