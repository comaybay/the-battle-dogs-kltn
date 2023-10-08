extends Node

signal bone_changed(value: int)
signal music_volume_changed(value: int)
signal sound_fx_volume_changed(value: int)
signal mute_music_changed(mute: bool)
signal mute_sound_fx_changed(mute: bool)
signal select_data

var save_data: Dictionary
var old_data: Dictionary
var silentwolf_data : Dictionary
var use_sw_data : bool	
var select_data_notif
var user_name: String:
	get: return save_data['user_name']
	set(value): save_data['user_name'] = value

var date: String:
	get: return save_data['date']		
	set(value): save_data['date'] = value	

var steam_first_login: bool:
	get: return save_data['steam_first_login']
	set(value): 
		save_data['steam_first_login'] = value

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

var fullscreen: bool:
	get: return save_data['settings']['fullscreen']
	set(value): save_data['settings']['fullscreen'] = value	

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
	# if player opens game for the first time
	if not FileAccess.file_exists("user://save.json"):
		save_data = _create_new_game_save()
	else:
		save_data = _load_game_save()		
	load_settings()

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

func _create_new_game_save() -> Dictionary:
	var new_game_save_file := FileAccess.open("res://resources/new_game_save.json", FileAccess.READ)
	var new_game_save_text := new_game_save_file.get_as_text()
	new_game_save_file.close()
	
	var save_file := FileAccess.open("user://save.json", FileAccess.WRITE)
	save_file.store_line(new_game_save_text)
	save_file.close()
	
	return JSON.parse_string(new_game_save_text)
	
func _load_game_save() -> Dictionary:
	var new_game_save_file := FileAccess.open("res://resources/new_game_save.json", FileAccess.READ)
	var new_game_save_data: Dictionary = JSON.parse_string(new_game_save_file.get_as_text())
	new_game_save_file.close()
	
	var file := FileAccess.open("user://save.json", FileAccess.READ)
	var save_data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	save_data = _compare_and_update_save_file(new_game_save_data, save_data)
	
	file = FileAccess.open("user://save.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()
	
	return save_data
	
## compare and update save data in case if the save data of an older version of the game
func _compare_and_update_save_file(new_game_save_data: Dictionary, save_data: Dictionary):
	for key in new_game_save_data:
		if not save_data.has(key):
			save_data[key] = new_game_save_data[key]
			continue
			
		if typeof(save_data[key]) != typeof(new_game_save_data[key]):
			save_data[key] = new_game_save_data[key]
			continue 
			
		if typeof(save_data[key]) == TYPE_DICTIONARY:
			_compare_and_update_save_file(new_game_save_data[key], save_data[key])
			
	return save_data
			
func _ready() -> void:
	select_data_notif = true
	old_data = save_data	
	## if player opens the game for the first time (game_language is not chose yet)
	use_sw_data = false
	if game_language == "":	
		get_tree().change_scene_to_file.call_deferred("res://scenes/new_game_preferences/new_game_preferences.tscn")
	
	GlobalControl.set_fullscreen(fullscreen)
	
func compute_values():
	dogs.clear()
	skills.clear()
	store.clear()
	passives.clear()
	
	for dog in save_data["dogs"]:
		dogs[dog["ID"]] = dog
	
	for skill in save_data["skills"]:
		skills[skill["ID"]] = skill
		
	for item in save_data["items"]:
		store[item["ID"]] = item
		
	for passive in save_data["passives"]:
		passives[passive["ID"]] = passive

func save():
	date = Time.get_datetime_string_from_system() #save_data.date == date
	
	if use_sw_data == false : # play offline
		var file = FileAccess.open("user://save.json", FileAccess.WRITE) 
		file.store_line(JSON.stringify(save_data))
		file.close()			
	else: #play online
		if (silentwolf_data["user_name"] == old_data["user_name"]):
			var date1 = Time.get_unix_time_from_datetime_string(save_data.date)
			var date2 =Time.get_unix_time_from_datetime_string(silentwolf_data.date)
			if date2 > date1: #luu silentwolf_data vao data			
				save_data = silentwolf_data				
			else : #luu data vao silentwolf_data				
				silentwolf_data = save_data
				SilentWolf.Players.save_player_data(Steam.getPersonaName(), silentwolf_data)
			var file = FileAccess.open("user://save.json", FileAccess.WRITE) 
			file.store_line(JSON.stringify(save_data))
			file.close()
		else : #silentwolf user_name != data user_name
			# dung sw_data			
			save_data = silentwolf_data 
			SilentWolf.Players.save_player_data(Steam.getPersonaName(), save_data)
			if select_data_notif == true :
				select_data.emit()
			
	compute_values()

func load_settings():
	TranslationServer.set_locale(game_language)	
	
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
	
