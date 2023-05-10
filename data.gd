extends Node

var bone
var dog_food
var level_pass
var level_select
var selected_team: Dictionary
var teams: Array
var save_data: Dictionary

func _init() -> void:
	var file = FileAccess.open("res://resources/save.json", FileAccess.READ)
	save_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	bone = save_data['bone']
	dog_food = save_data['dog_food']
	level_pass = save_data['passed_level']
	level_select = save_data['selected_level']
	teams = save_data['teams']
	selected_team = teams[save_data['selected_team']]
	
func save():
	var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
	file.write(JSON.stringify(save_data))
	file.close()
		
