@tool
class_name FSMState extends Node

signal transition (state_path: String, data: Dictionary)

# this is used to check if this node is a FSM state
var is_FSM_state = true

func _init() -> void:
	if Engine.is_editor_hint():
		return
	
	assert(get_script().is_tool(), "Please make your script a tool script (by adding '@tool' at the begining of the file).")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	
	if not has_method("enter"):
		warnings.append("Please define method 'enter', this method is called when the state is activated.")
	
	return warnings
