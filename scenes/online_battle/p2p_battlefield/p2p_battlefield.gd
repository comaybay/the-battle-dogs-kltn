class_name P2PBattlefield extends BaseBattlefield

var VictoryGUI: PackedScene = preload("res://scenes/battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefield/defeat_gui/defeat_gui.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")

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
	_stage_width = int(SteamUser.get_lobby_data("stage_width"))
	var is_server: bool = SteamUser.get_lobby_owner() == SteamUser.STEAM_ID
	InBattle.in_p2p_battle = true
	InBattle.in_request_mode = not is_server
	
	for member_id in SteamUser.lobby_members:
		if member_id == SteamUser.STEAM_ID:
			_this_player_data = P2PBattlefieldPlayerData.new(member_id)
		else:
			_opponent_player_data = P2PBattlefieldPlayerData.new(member_id)

func _ready() -> void:
	inbattle_sfx_idx = AudioServer.get_bus_index("InBattleFX")
	var stage_width_with_margin = _stage_width + (TOWER_MARGIN * 2)
	
	$ConnectionHandler.setup(%Popup)
	$Camera2D.setup(($Gui as P2PBattleGUI).camera_control_buttons, stage_width_with_margin, get_stage_height())
	AudioPlayer.play_music(load("res://resources/sound/music/%s.mp3" % SteamUser.get_lobby_data("music")))
	
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % SteamUser.get_lobby_data("theme"))
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width_with_margin
	
	_player_dog_tower = $P2PDogTowerLeft as P2PDogTower
	_opponent_dog_tower = $P2PDogTowerRight as P2PDogTower
	
	var half_viewport_size = Global.VIEWPORT_SIZE / 2
	$Camera2D.position = Vector2(0, -half_viewport_size.y)
	
	if SteamUser.STEAM_ID != SteamUser.get_lobby_owner():
		_player_dog_tower = $P2PDogTowerRight
		_opponent_dog_tower = $P2PDogTowerLeft
		$Camera2D.position = Vector2(_stage_width, -half_viewport_size.y)
	
	$P2PDogTowerLeft.position.x = TOWER_MARGIN
	$P2PDogTowerRight.position.x = stage_width_with_margin - TOWER_MARGIN
	
	var is_server: bool = SteamUser.get_lobby_owner() == SteamUser.STEAM_ID
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

	_player_dog_tower.zero_health.connect(_show_defeat_ui, CONNECT_ONE_SHOT)
	_opponent_dog_tower.zero_health.connect(_show_win_ui, CONNECT_ONE_SHOT)
	
func _show_win_ui():
	clean_up()
	var current_music = AudioPlayer.get_current_music()
	AudioPlayer.stop_music(current_music, true, true)
	AudioPlayer.play_music(VICTORY_AUDIO)
	add_child(VictoryGUI.instantiate())	
	
func _show_defeat_ui():
	clean_up()
	var current_music = AudioPlayer.get_current_music()
	AudioPlayer.stop_music(current_music, true, true)
	AudioPlayer.play_music(DEFEAT_AUDIO)
	add_child(DefeatGUI.instantiate())	
	
func clean_up():
	$Camera2D.allow_user_input_camera_movement(false)
	
	$Gui.queue_free()
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, -80)	

func _exit_tree() -> void:
	var current_music := AudioPlayer.get_current_music()
	if current_music:
		AudioPlayer.stop_music(current_music, true, true)
		
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, 0)
	
