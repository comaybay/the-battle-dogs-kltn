@tool
class_name FSMState extends Node

signal transition (state_path: String, data: Dictionary)

# this is used to check if this node is a FSM state
var is_FSM_state = true

func _init() -> void:
	assert(get_script().is_tool(), "Please make your script a tool script (by adding '@tool' at the begining of the file).")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	
	if not has_method("enter"):
		warnings.append("Please define method 'enter', this method is called when the state is activated.")
	
	if not has_method("exit"):
		warnings.append("Please define method 'exit', this method is called when the state is deactivated.")
		
	if not has_method("update"):
		warnings.append("Please define method 'update', this method is called every frame when the state is active.")
			
	if not has_method("input"):
		warnings.append("Please define method 'input', this method is the equivalent of _input but only called when the state is active.")
	
	return warnings
