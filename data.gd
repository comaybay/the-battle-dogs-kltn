extends Node

signal bone_changed(value: int)
signal music_volume_changed(value: int)
signal sound_fx_volume_changed(value: int)

var save_data: Dictionary

var bone: int:
	get: return save_data['bone']		
	set(value): 
		save_data['bone'] = value
		bone_changed.emit(value)		

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

var sound_fx_volume: int:
	get: return save_data['settings']['sound_fx']		
	set(value): 
		save_data['settings']['sound_fx'] = value	
		sound_fx_volume_changed.emit(value)
		
var music_volume: int:
	get: return save_data['settings']['music']		
	set(value): 
		save_data['settings']['music'] = value	
		music_volume_changed.emit(value)

var dog_info := Dictionary()
var store_info := Dictionary()
var skill_info := Dictionary()
var dogs := Dictionary()
var skills := Dictionary()
var store := Dictionary()

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
	
	file = FileAccess.open("res://resources/game_data/store.json", FileAccess.READ)
	var store_info_arr = JSON.parse_string(file.get_as_text())
	for info in store_info_arr:
		store_info[info['ID']] = info
	file.close()
	
	compute_values()

func compute_values():
	for dog in save_data["dogs"]:
		dogs[dog["ID"]] = dog
	
	for skill in save_data["skills"]:
		skills[skill["ID"]] = skill
		
	for item in save_data["items"]:
		store[item["ID"]] = item

func save():
	var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()
	compute_values()
