extends CanvasLayer

var _debug_mode := false 
var _draw_debug := false 

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_debug_mode = OS.is_debug_build()
	
	if not _debug_mode:
		set_process_input(false)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_draw_debug'):
		_draw_debug = !_draw_debug
		
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
		Data.passed_stage = 99
		Data.bone = 999999999
		Data.save()
		
	if event.is_action_pressed('ui_debug_switch_language'):
		TranslationServer.set_locale("en" if TranslationServer.get_locale() == "vi" else "vi")	

	if event.is_action_pressed('ui_debug_kill_cats'):
		for cat in get_tree().get_nodes_in_group("cats"):
			cat.take_damage(999999999)

	if event.is_action_pressed('ui_debug_win_battle'):
		InBattle.get_battlefield().get_cat_tower().zero_health.emit()

func is_debug_mode() -> bool:
	return _debug_mode

func is_draw_debug() -> bool:
	return _draw_debug
