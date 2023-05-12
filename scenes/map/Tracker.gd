extends Node2D

var mouse_pressed = false
var last_mouse_pos = Vector2.ZERO

func setup(levels: Array[Node], map: Sprite2D):
	var map_size := map.get_rect().size
	$Camera2D.limit_left = 0
	$Camera2D.limit_right = map_size.x
	$Camera2D.limit_top = 0
	$Camera2D.limit_bottom = map_size.y
	
	for node in levels:
		var level: Level = node
		level.focus_entered.connect(_move_to_level.bind(level))

func _move_to_level(level: Level):
	position = level.position

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

