class_name BaseBattlefield extends Node2D

## margin for position.x of cat tower and dog tower
const TOWER_MARGIN: int = 700

func get_stage_width() -> int:
	push_error("ERROR: get_stage_width() NOT IMPLEMENTED")
	return 1

func get_player_data() -> BaseBattlefieldPlayerData:
	push_error("ERROR: get_player_data() NOT IMPLEMENTED")
	return null	

func get_theme() -> String:
	push_error("ERROR: get_theme() NOT IMPLEMENTED")
	return ""
