class_name Tracker extends Node2D

const STAGE_SELECTED_AUDIO: AudioStream = preload("res://resources/sound/stage_selected.wav")

signal move_stage(target_stage: Stage)

var mouse_pressed = false
var last_mouse_pos = Vector2.ZERO
var current_stage: Stage
var passed_stage: Stage
var is_mouse_entered: bool
var _stage_chain: HSlideSelection
var _first_time_focus: bool = true

func setup(stages: Array[Node], stage_chain: HSlideSelection, map: Sprite2D, drag_area: Control):
	var map_size := map.get_rect().size
	$Camera2D.limit_left = 0
	$Camera2D.limit_right = map_size.x
	$Camera2D.limit_top = 0
	$Camera2D.limit_bottom = map_size.y
	
	_stage_chain = stage_chain
	current_stage = stages[Data.selected_stage]
	passed_stage = stages[Data.passed_stage] if Data.passed_stage >= 0 else null  
	
	drag_area.mouse_entered.connect(func(): is_mouse_entered = true)
	drag_area.mouse_exited.connect(func(): is_mouse_entered = false)
	
	stage_chain.item_focus.connect(
		func(item): 
			_move_to_stage(item.stage, not _first_time_focus)
			_first_time_focus = false
	)
	
	for stage in stages:
		stage.pressed.connect(
			func():
				_move_to_stage(stage, false)
				_stage_chain.focus(stage.index)
		)
		
	for stage_box in stage_chain.get_items():
		stage_box.pressed.connect(
			func():
				_move_to_stage(stage_box.stage, false)
		)
	
	_move_to_stage(current_stage, false)
		
func _move_to_stage(stage: Stage, play_sound := true):
	if play_sound:
		AudioPlayer.play_sfx(STAGE_SELECTED_AUDIO)
	
	current_stage.set_selected(false)
	stage.set_selected(true)
	
	position = stage.position #Di chuyen tracker
	move_stage.emit(stage)
	current_stage = stage

func _input(event):
#	if event.is_action_pressed("ui_left") and current_stage.prev_stage != null:
#		_move_to_stage(current_stage.prev_stage)
#
#	elif event.is_action_pressed("ui_right") and current_stage.next_stage != null and Data.passed_stage >= 0 and current_stage.index <= Data.passed_stage:
#		_move_to_stage(current_stage.next_stage)
	
	if not is_mouse_entered and not mouse_pressed:
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

func get_camera() -> Camera2D:
	return $Camera2D 
