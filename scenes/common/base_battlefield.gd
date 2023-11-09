class_name BaseBattlefield extends Node2D

## margin for position.x of cat tower and dog tower
const TOWER_MARGIN: int = 700

func get_stage_width() -> int:
	push_error("ERROR: get_stage_width() NOT IMPLEMENTED")
	return 1

func get_stage_height() -> int: return $Sky.size.y

func get_player_data() -> BaseBattlefieldPlayerData:
	push_error("ERROR: get_player_data() NOT IMPLEMENTED")
	return null	

func get_theme() -> String:
	push_error("ERROR: get_theme() NOT IMPLEMENTED")
	return ""

## The effect space, this is where all the effects should be placed.
## stuff that are placed here will always be in front of the characters
func get_effect_space() -> Node2D:
	return $EffectSpace

func _clean_up():
	# set back to 1 in case user change game speed
	Engine.time_scale = 1
	$Camera2D.allow_user_input_camera_movement(false)
	
	$Gui.queue_free()
	var inbattle_sfx_idx: int = AudioServer.get_bus_index("InBattleFX")
	AudioServer.set_bus_mute(inbattle_sfx_idx, true)	

func _exit_tree() -> void:
	# in case game is paused (for example by quitting the battle from pause menu) 
	get_tree().paused = false
	
	var current_music := AudioPlayer.get_current_music()
	if current_music:
		AudioPlayer.stop_music(current_music, true, true)
		
	AudioPlayer.remove_all_in_battle_sfx()
	
	var inbattle_sfx_idx: int = AudioServer.get_bus_index("InBattleFX")
	AudioServer.set_bus_mute(inbattle_sfx_idx, false)	
