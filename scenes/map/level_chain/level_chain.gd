class_name LevelChain extends SubViewportContainer

const LevelBox: PackedScene = preload("res://scenes/map/level_chain/level_box.tscn")

var level_boxes: Array[LevelBox] 
@onready var viewport_size = $SubViewport.size
var mouse_pressed := false
var last_mouse_pos: Vector2
var selected_level_box: LevelBox
var is_mouse_entered: bool

func _ready() -> void:
	mouse_entered.connect(func(): is_mouse_entered = true)
	mouse_exited.connect(func(): is_mouse_entered = false)

func setup(levels: Array[Node]):
	for level in levels:
		var level_box = LevelBox.instantiate()
		level_box.setup(level)
		level_box.pressed.connect(_on_level_box_preesed.bind(level_box))
		$SubViewport/HBoxContainer.add_child(level_box)
		level_boxes.append(level_box)

	%Camera2D.limit_top = 0
	%Camera2D.limit_bottom = 0
	
	# wait for level boxes name to be loaded in (which will change the size of HBox)
	var first_box = level_boxes.front()
	var last_box = level_boxes.back() 
	selected_level_box = level_boxes[Data.selected_level]
	
	$SubViewport/HBoxContainer.sort_children.connect(func(): 
		%Camera2D.limit_left = _get_camera_position_from(first_box).x
		%Camera2D.limit_right = _get_camera_position_from(last_box).x + viewport_size.x
		focus_camera_to(selected_level_box.level.index)
	)	
	
func _on_level_box_preesed(level_box: LevelBox):
	if selected_level_box != level_box:
		focus_camera_to(level_box.level.index)

func focus_camera_to(level_number: int):
	selected_level_box.set_selected(false)
	selected_level_box = level_boxes[level_number]
	selected_level_box.set_selected(true)
	%Camera2D.position = _get_camera_position_from(selected_level_box)

func _get_camera_position_from(level_box: LevelBox):
	var box_position = level_box.position + (level_box.size / 2)
	return Vector2(box_position.x - (viewport_size.x / 2), 0)

func _input(event):
	if not is_mouse_entered and not mouse_pressed:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mouse_pressed = true
				last_mouse_pos = event.position
			else:
				mouse_pressed = false
				%Camera2D.position_smoothing_speed = 6
		else:
			mouse_pressed = false
			
	if event is InputEventMouseMotion and mouse_pressed:
		%Camera2D.position_smoothing_speed = 30
		var delta = last_mouse_pos.x - event.position.x
		%Camera2D.position.x = clamp(%Camera2D.position.x + (delta * 2), %Camera2D.limit_left, %Camera2D.limit_right - viewport_size.x) 
		last_mouse_pos = event.position
