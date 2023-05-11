extends Node

var bone
var dog_food
var passed_level: int
var selected_level:int
var selected_team: Dictionary
var teams: Array
var save_data: Dictionary
var dog_info := Dictionary()
var selected_battlefield_id: String

func _init() -> void:
	var file = FileAccess.open("res://resources/save.json", FileAccess.READ)
	save_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	bone = save_data['bone']
	dog_food = save_data['dog_food']
	passed_level = save_data['passed_level']
	selected_level = save_data['selected_level']
	teams = save_data['teams']
	selected_team = teams[save_data['selected_team']]
	selected_battlefield_id = save_data['selected_battlefield_id']
	
	file = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	
	
	var dog_info_arr = JSON.parse_string(file.get_as_text())
	for info in dog_info_arr:
		dog_info[info['name_id']] = info
	
	file.close()
	
	
func save():
	var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
	file.write(JSON.stringify(save_data))
	file.close()
		
