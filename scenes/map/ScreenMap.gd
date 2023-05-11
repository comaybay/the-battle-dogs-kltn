extends Node2D

var mouse_pressed = false
var last_mouse_pos = Vector2.ZERO
@export var level_now = 3

var game_data

func _ready():
	game_data = Data.save_data
	mouse_pressed = false
	
	# focus on selected level
	for node in $Node.get_children():
		var level: Level = node
		if level.battlefield_id == Data.selected_battlefield_id:
			level.grab_focus()
			break
		


func _draw() -> void:
	var allMap = $Node.get_children()	
	for level in game_data['passed_level']:
		var vitri1 = allMap[level].position + Vector2(20,20)
		var vitri2 = allMap[level+1].position+ Vector2(20,20)
		draw_dashed_line(vitri1,vitri2, Color(1, 1, 1, 1), 4, 10, false)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				mouse_pressed = true
				last_mouse_pos = event.position
			else:
				mouse_pressed = false
		else:
			mouse_pressed = false
	if event is InputEventMouseMotion and mouse_pressed:
		var delta = last_mouse_pos - event.position
		position -= delta
		last_mouse_pos = event.position

