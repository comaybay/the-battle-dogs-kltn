extends Node

var _debug_mode := false 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_debug_mode'):
		_debug_mode = !_debug_mode
		
		for node in get_tree().get_nodes_in_group('character'):
			node.queue_redraw()

func is_debug_mode() -> bool:
	return _debug_mode
