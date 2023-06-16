class_name Tracker extends Node2D

signal move_level(target_level: Level)

var mouse_pressed = false
var last_mouse_pos = Vector2.ZERO
var current_level: Level
var passed_level: Level
var is_mouse_entered: bool
var _level_chain: LevelChain

func setup(levels: Array[Node], level_chain: LevelChain, map: Sprite2D, drag_area: Control):
	var map_size := map.get_rect().size
	$Camera2D.limit_left = 0
	$Camera2D.limit_right = map_size.x
	$Camera2D.limit_top = 0
	$Camera2D.limit_bottom = map_size.y
	
	_level_chain = level_chain
	current_level = levels[Data.selected_level]
	passed_level = levels[Data.passed_level] if Data.passed_level > 0 else null  
	
	drag_area.mouse_entered.connect(func(): is_mouse_entered = true)
	drag_area.mouse_exited.connect(func(): is_mouse_entered = false)
	
	for level in levels:
		level.pressed.connect(_move_to_level.bind(level))
		
	for level_box in level_chain.level_boxes:
		level_box.pressed.connect(_move_to_level.bind(level_box.level))
	
	_move_to_level(current_level, false)
		
func _move_to_level(level: Level, play_sound := true):
	if play_sound:
		AudioPlayer.play_button_pressed_audio()
	
	_level_chain.focus_camera_to(level.index)
	current_level.set_selected(false)
	level.set_selected(true)
	position = level.position #Di chuyen tracker
	move_level.emit(level)
	current_level = level

func _input(event):
	if event.is_action_pressed("ui_left") and current_level.prev_level != null:
		_move_to_level(current_level.prev_level)
	
	elif event.is_action_pressed("ui_right") and current_level.next_level != null and Data.passed_level > 0 and current_level.index <= passed_level.index:
		_move_to_level(current_level.next_level)
	
	if !is_mouse_entered:
		return
	
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
