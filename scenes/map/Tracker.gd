class_name Tracker extends Node2D

signal move_level(target_level: Level)

var mouse_pressed = false
var last_mouse_pos = Vector2.ZERO
var current_level: Level
var passed_level: Level

func setup(levels: Array[Node], map: Sprite2D):
	var map_size := map.get_rect().size
	$Camera2D.limit_left = 0
	$Camera2D.limit_right = map_size.x
	$Camera2D.limit_top = 0
	$Camera2D.limit_bottom = map_size.y
	
	current_level = levels[Data.selected_level]
	passed_level = levels[Data.passed_level]
	
	for level in levels:
		level.pressed.connect(_move_to_level.bind(level))
		
	_move_to_level(current_level)
		
func _move_to_level(level: Level):
	current_level.set_selected(false)
	level.set_selected(true)
	position = level.position
	move_level.emit(level)
	current_level = level

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mouse_pressed = true
				last_mouse_pos = event.position
			else:
				mouse_pressed = false
				$Camera2D.position_smoothing_speed = 6
		else:
			mouse_pressed = false
			
	if event is InputEventMouseMotion and mouse_pressed:
		$Camera2D.position_smoothing_speed = 20
		var delta = last_mouse_pos - event.position
		position += delta
		last_mouse_pos = event.position

	if event.is_action_pressed("ui_left") and current_level.prev_level != null:
		_move_to_level(current_level.prev_level)
	
	elif event.is_action_pressed("ui_right") and current_level.next_level != null and current_level.index <= passed_level.index:
		_move_to_level(current_level.next_level)


