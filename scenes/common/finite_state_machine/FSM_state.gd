class_name FSMState extends Node

signal transition (state_path: String, data: Dictionary)

# this is used to check if this node is a FSM state
var is_FSM_state = true

func enter(_data: Dictionary) -> void:
	push_error("ERROR: Please define method 'enter', this method is called when the state is activated")
