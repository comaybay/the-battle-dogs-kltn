class_name P2PBattlefield extends BaseBattlefield

var GAME_END_SCENE: PackedScene = preload("res://scenes/online_battle/p2p_battlefield/p2p_game_end_gui/p2p_game_end_gui.tscn")

var inbattle_sfx_idx: int

var _p2p_networking: BattlefieldP2PNetworking
func get_p2p_networking() -> BattlefieldP2PNetworking: return _p2p_networking

var _stage_width: int
func get_stage_width() -> int: return _stage_width

var _opponent_player_data: P2PBattlefieldPlayerData
var _this_player_data: P2PBattlefieldPlayerData
func get_this_player_data() -> P2PBattlefieldPlayerData: return _this_player_data

func get_player_data() -> BaseBattlefieldPlayerData: return _this_player_data

func get_theme() -> String: return SteamUser.get_lobby_data("theme")

var _player_dog_tower: P2PDogTower
func get_this_player_dog_tower() -> P2PDogTower: return _player_dog_tower

var _opponent_dog_tower: P2PDogTower
func get_enemy_dog_tower() -> P2PDogTower: return _opponent_dog_tower

func get_dog_tower_left() -> P2PDogTower:
	return $P2PDogTowerLeft
	
func get_dog_tower_right() -> P2PDogTower:
	return $P2PDogTowerRight

func _enter_tree() -> void:
	get_tree().paused = true
	process_mode = PROCESS_MODE_ALWAYS
	Steam.lobby_data_update.connect(_start_game_when_all_is_ready)
	%Popup.popup("@WAITTING_FOR_OTHER_PLAYER_IN_BATTLE", PopupDialog.Type.PROGRESS)
	
	_stage_width = int(SteamUser.get_lobby_data("stage_width"))
	var is_server: bool = SteamUser.players[0]['steam_id'] == SteamUser.STEAM_ID
	InBattle.in_p2p_battle = true
	InBattle.in_request_mode = not is_server
	
	for player_data in SteamUser.players:
		var member_id: int = player_data['steam_id']
		if member_id == SteamUser.STEAM_ID:
			_this_player_data = P2PBattlefieldPlayerData.new(member_id)
		else:
			_opponent_player_data = P2PBattlefieldPlayerData.new(member_id)

func _ready() -> void:
	inbattle_sfx_idx = AudioServer.get_bus_index("InBattleFX")
	var stage_width_with_margin = _stage_width + (TOWER_MARGIN * 2)
	
	$P2PConnectionHandler.setup(%Popup)
	$Camera2D.setup(($Gui as P2PBattleGUI).camera_control_buttons, stage_width_with_margin, get_stage_height())
	AudioPlayer.play_music(load("res://resources/sound/music/%s.mp3" % SteamUser.get_lobby_data("music")))
	
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % SteamUser.get_lobby_data("theme"))
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width_with_margin
	
	_player_dog_tower = $P2PDogTowerLeft as P2PDogTower
	_opponent_dog_tower = $P2PDogTowerRight as P2PDogTower
	
	var half_viewport_size = Global.VIEWPORT_SIZE / 2
	$Camera2D.position = Vector2(0, -half_viewport_size.y)
	
	if SteamUser.STEAM_ID != SteamUser.players[0]['steam_id']:
		_player_dog_tower = $P2PDogTowerRight
		_opponent_dog_tower = $P2PDogTowerLeft
		$Camera2D.position = Vector2(_stage_width, -half_viewport_size.y)
	
	$P2PDogTowerLeft.position.x = TOWER_MARGIN
	$P2PDogTowerRight.position.x = stage_width_with_margin - TOWER_MARGIN
	
	var is_server: bool = SteamUser.players[0]['steam_id'] == SteamUser.STEAM_ID
	if is_server:
		_p2p_networking = $ServerSide
		$ServerSide.setup(_this_player_data, _opponent_player_data, _player_dog_tower, _opponent_dog_tower)
		$ClientSide.queue_free()
	else:
		_p2p_networking = $ClientSide
		$ClientSide.setup(self, _this_player_data, _opponent_player_data, _player_dog_tower, _opponent_dog_tower)
		$ServerSide.queue_free()
	
	_player_dog_tower.setup(true, _this_player_data)
	_opponent_dog_tower.setup(false, _opponent_player_data)
	
	$Gui.setup(_player_dog_tower, _this_player_data)
	
	SteamUser.set_lobby_member_data("in_battle_ready", "true")

func _start_game_when_all_is_ready(success: int, lobby_id: int, member_id: int) -> void:
	if success == 0 or member_id == lobby_id:
		return
		
	var is_everyone_ready = SteamUser.players.all(func(player):
		return SteamUser.get_member_data(player['steam_id'], "in_battle_ready") == "true"
	)
	
	if is_everyone_ready:
		process_mode = PROCESS_MODE_ALWAYS
		get_tree().paused = false
		Steam.lobby_data_update.disconnect(_start_game_when_all_is_ready)
		%Popup.close()
		
func end_game(winner_id: int):
	clean_up()

	var game_end: P2PGameEndGUI = GAME_END_SCENE.instantiate()
	game_end.setup(winner_id)	

	add_child(game_end)	
	
func clean_up():
	var is_server: bool = SteamUser.players[0]['steam_id'] == SteamUser.STEAM_ID
	if is_server:
		$ServerSide.set_process(false)
		$ServerSide.queue_free()
	else:
		$ClientSide.set_process(false)
		$ClientSide.queue_free()
	
	$Camera2D.allow_user_input_camera_movement(false)
	SteamUser.set_lobby_data("game_status", "waiting")
	$Gui.queue_free()
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, -80)	

func _exit_tree() -> void:
	var current_music := AudioPlayer.get_current_music()
	if current_music:
		AudioPlayer.stop_music(current_music, true, true)
		
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, 0)
	
