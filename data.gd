extends Node

signal bone_changed(value: int)
signal music_volume_changed(value: int)
signal sound_fx_volume_changed(value: int)
signal mute_music_changed(mute: bool)
signal mute_sound_fx_changed(mute: bool)

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
	get: return save_data['settings']['sound_fx']['volume']		
	set(value): 
		save_data['settings']['sound_fx']['volume'] = value	
		sound_fx_volume_changed.emit(value)
		
var music_volume: int:
	get: return save_data['settings']['music']['volume']		
	set(value): 
		save_data['settings']['music']['volume'] = value	
		music_volume_changed.emit(value)

var mute_music: bool:
	get: return save_data['settings']['music']['mute']		
	set(value): 
		save_data['settings']['music']['mute'] = value	
		mute_music_changed.emit(value)	
		
var mute_sound_fx: bool:
	get: return save_data['settings']['sound_fx']['mute']		
	set(value): 
		save_data['settings']['sound_fx']['mute'] = value	
		mute_sound_fx_changed.emit(value)	
		
var game_language: String:
	get: return save_data['settings']['language']
	set(value): save_data['settings']['language'] = value	

var has_done_battlefield_basics_tutorial: bool:	
	get: return save_data['tutorial']['battlefield_basics']
	set(value): save_data['tutorial']['battlefield_basics'] = value

var has_done_battlefield_boss_tutorial: bool:
	get: return save_data['tutorial']['boss']
	set(value): save_data['tutorial']['boss'] = value

var has_done_battlefield_final_boss_tutorial: bool:
	get: return save_data['tutorial']['final_boss']
	set(value): save_data['tutorial']['final_boss'] = value

var has_done_battlefield_rush: bool:
	get: return save_data['tutorial']['battlefield_rush']
	set(value): save_data['tutorial']['battlefield_rush'] = value

var has_done_map_tutorial: bool:
	get: return save_data['tutorial']['map']
	set(value): save_data['tutorial']['map'] = value

var has_done_upgrade_tutorial: bool:
	get: return save_data['tutorial']['upgrade']
	set(value): save_data['tutorial']['upgrade'] = value
	
var has_done_team_setup_tutorial: bool:
	get: return save_data['tutorial']['team_setup']
	set(value): save_data['tutorial']['team_setup'] = value

var has_done_dogbase_tutorial: bool:
	get: return save_data['tutorial']['dogbase']
	set(value): save_data['tutorial']['dogbase'] = value

var has_done_dogbase_after_battlefield_tutorial: bool:
	get: return save_data['tutorial']['dogbase_after_battlefield']
	set(value): save_data['tutorial']['dogbase_after_battlefield'] = value

## count everytime player lost in a tutorial 
var tutorial_lost: int = 0 

# general info
var dog_info := Dictionary()
var store_info := Dictionary()
var skill_info := Dictionary()
var passive_info := Dictionary()

# save data
var dogs := Dictionary()
var skills := Dictionary()
var store := Dictionary()
var passives := Dictionary()

func _init() -> void:
	# new game
	if not FileAccess.file_exists("user://save.json"):
		var file: = FileAccess.open("res://resources/new_game_save.json", FileAccess.READ)
		var new_game_save_text := file.get_as_text()
		
		file = FileAccess.open("user://save.json", FileAccess.WRITE)
		file.store_line(new_game_save_text)
		file.close()
		
		save_data = JSON.parse_string(new_game_save_text)
	else:
		var file := FileAccess.open("user://save.json", FileAccess.READ)
		save_data = JSON.parse_string(file.get_as_text())
		file.close()
		TranslationServer.set_locale(game_language)	
		
	_load_settings()

	var file := FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
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
	
	file = FileAccess.open("res://resources/game_data/passives.json", FileAccess.READ)
	var passive_info_arr = JSON.parse_string(file.get_as_text())
	for info in passive_info_arr:
		passive_info[info['ID']] = info
	file.close()
	
	compute_values()

func _ready() -> void:
	if game_language == "":	
		get_tree().change_scene_to_file.call_deferred("res://scenes/new_game_preferences/new_game_preferences.tscn")
	
	if save_data['settings']['fullscreen']:
		GlobalControl.set_fullscreen(true)
	

func compute_values():
	for dog in save_data["dogs"]:
		dogs[dog["ID"]] = dog
	
	for skill in save_data["skills"]:
		skills[skill["ID"]] = skill
		
	for item in save_data["items"]:
		store[item["ID"]] = item
		
	for passive in save_data["passives"]:
		passives[passive["ID"]] = passive

func save():
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()
	compute_values()

func _load_settings():
	var sound_fx_idx = AudioServer.get_bus_index("SoundFX")
	var music_idx = AudioServer.get_bus_index("Music")
	
	AudioServer.set_bus_volume_db(sound_fx_idx, linear_to_db(0 if mute_sound_fx else (sound_fx_volume / 100.0)))
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(0 if mute_music else (music_volume / 100.0)))
	
	var key_overwrites: Dictionary = save_data['settings']['key_binding_overwrites']
	
	for action in key_overwrites.keys():
		var event = InputEventKey.new()
		event.keycode = key_overwrites[action]
		
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)	
	
