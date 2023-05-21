extends Node

var save_data: Dictionary

var bone: int:
	get: return save_data['bone']		
	set(value): save_data['bone'] = value		

var dog_food: int:
	get: return save_data['dog_food']		
	set(value): save_data['dog_food'] = value		

var passed_level: int:
	get: return save_data['passed_level']		
	set(value): save_data['passed_level'] = value		

var selected_level: int:
	get: return save_data['selected_level']		
	set(value): save_data['selected_level'] = value		

var selected_team: Dictionary:
	get: return teams[save_data['selected_team']]		
	set(value): teams[save_data['selected_team']] = value		

var teams: Array:
	get: return save_data['teams']		
	set(value): save_data['teams'] = value		

var selected_battlefield_id: String:
	get: return save_data['selected_battlefield_id']		
	set(value): save_data['selected_battlefield_id'] = value		

var dog_info := Dictionary()
var skill_info := Dictionary()
func _init() -> void:
	var file = FileAccess.open("res://resources/save.json", FileAccess.READ)
	save_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	file = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	var dog_info_arr = JSON.parse_string(file.get_as_text())
	for info in dog_info_arr:
		dog_info[info['ID']] = info
	file.close()
	
	file = FileAccess.open("res://resources/game_data/skill.json", FileAccess.READ)
	var skill_info_arr = JSON.parse_string(file.get_as_text())
	for info in skill_info_arr:
		skill_info[info['ID']] = info
	file.close()
	
	
func save():
	var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()
