extends Node

var _debug_mode := false 

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_debug_mode'):
		_debug_mode = !_debug_mode
		
		for node in get_tree().get_nodes_in_group('characters'):
			node.queue_redraw()

	if event.is_action_pressed('ui_debug_speed'):
		Engine.time_scale = 10 if Engine.time_scale == 1 else 1
	
	if event.is_action_pressed('ui_debug_battlefield_money'):
		var battlefield = get_tree().current_scene
		if battlefield is BaseBattlefield:
			var player_data: BaseBattlefieldPlayerData = battlefield.get_player_data()
			for i in range(player_data.MAX_EFFICIENCY_LEVEL - player_data.get_efficiency_level()):
				player_data.increase_efficiency_level()
			
			player_data.fmoney = player_data.get_wallet_capacity()
	
	if event.is_action_pressed('ui_debug_save_file'):
		Data.passed_level = 12
		Data.bone = 999999999
		Data.save()
		
	if event.is_action_pressed('ui_debug_switch_language'):
		TranslationServer.set_locale("en" if TranslationServer.get_locale() == "vi" else "vi")	

func is_debug_mode() -> bool:
	return _debug_mode

func _ready() -> void:
	if not OS.is_debug_build():
		set_process_input(false)
