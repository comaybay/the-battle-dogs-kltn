extends Node

var _debug_mode := false 

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_debug_mode'):
		_debug_mode = !_debug_mode
		
		for node in get_tree().get_nodes_in_group('character'):
			node.queue_redraw()

	if event.is_action_pressed('ui_debug_speed'):
		Engine.time_scale = 10 if Engine.time_scale == 1 else 1
		
	if event.is_action_pressed('ui_debug_save_file'):
		Data.passed_level = 12
		Data.bone = 999999999
		Data.save()

func is_debug_mode() -> bool:
	return _debug_mode

func _ready() -> void:
	if not OS.is_debug_build():
		set_process_input(false)
