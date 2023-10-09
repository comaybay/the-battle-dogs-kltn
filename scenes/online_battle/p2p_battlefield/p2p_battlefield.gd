class_name OnlineBattlefield extends BaseBattlefield

var VictoryGUI: PackedScene = preload("res://scenes/battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefield/defeat_gui/defeat_gui.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")

var inbattle_sfx_idx: int

var _is_server: bool
func is_server() -> bool: return _is_server

var _p2p_networking: BattlefieldP2PNetworking
func get_p2p_networking() -> BattlefieldP2PNetworking: return _p2p_networking

var _stage_width: int
func _get_stage_width() -> int: return _stage_width

var _opponent_player_data: OnlineBattlefieldPlayerData
var _this_player_data: OnlineBattlefieldPlayerData
func get_this_player_data() -> OnlineBattlefieldPlayerData: return _this_player_data

func get_player_data() -> BaseBattlefieldPlayerData: return _this_player_data

func get_theme() -> String: return SteamUser.get_lobby_data("theme")

func _enter_tree() -> void:
	_stage_width = int(SteamUser.get_lobby_data("stage_width"))
	_is_server = SteamUser.get_lobby_owner() == SteamUser.STEAM_ID
	
	for member_id in SteamUser.lobby_members:
		var team_setup = JSON.parse_string(SteamUser.get_member_data(member_id, "team_setup"))
		if member_id == SteamUser.STEAM_ID:
			_this_player_data = OnlineBattlefieldPlayerData.new(team_setup)
		else:
			_opponent_player_data = OnlineBattlefieldPlayerData.new(team_setup)

func _ready() -> void:
	inbattle_sfx_idx = AudioServer.get_bus_index("InBattleFX")
	
	$ConnectionHandler.setup(%Popup)
	$Camera2D.setup(($Gui as OnlineBattleGUI).camera_control_buttons, _stage_width)
	$Music.stream = load("res://resources/sound/music/%s.mp3" % SteamUser.get_lobby_data("music"))
	$Music.play()
	
	var half_viewport_size = get_viewport().size / 2
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % SteamUser.get_lobby_data("theme"))
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = _stage_width
	
	var player_dog_tower := $OnlineDogTowerLeft as OnlineDogTower
	var opponent_dog_tower := $OnlineDogTowerRight as OnlineDogTower
	$Camera2D.position = Vector2(0, -half_viewport_size.y)
	
	if SteamUser.lobby_members[0] != SteamUser.STEAM_ID:
		player_dog_tower = $OnlineDogTowerRight
		opponent_dog_tower = $OnlineDogTowerLeft
		$Camera2D.position = Vector2(_stage_width, -half_viewport_size.y)
	
	$OnlineDogTowerLeft.position.x = TOWER_MARGIN
	$OnlineDogTowerRight.position.x = _stage_width - TOWER_MARGIN;
	
	$Land.position.x = _stage_width / 2.0
		
	if _is_server:
		_p2p_networking = $ServerSide
		$ServerSide.setup(_this_player_data, _opponent_player_data, player_dog_tower, opponent_dog_tower)
		$ClientSide.queue_free()
	else:
		_p2p_networking = $ClientSide
		$ClientSide.setup(_this_player_data, _opponent_player_data, player_dog_tower, opponent_dog_tower)
		$ServerSide.queue_free()
	
	player_dog_tower.setup(true, _this_player_data)
	opponent_dog_tower.setup(false, _opponent_player_data)
	
	$Gui.setup(player_dog_tower, _this_player_data)

	player_dog_tower.zero_health.connect(_show_defeat_ui, CONNECT_ONE_SHOT)
	opponent_dog_tower.zero_health.connect(_show_win_ui, CONNECT_ONE_SHOT)
	
func _show_win_ui():
	clean_up()
	$Music.stream = VICTORY_AUDIO
	$Music.play() 
	add_child(VictoryGUI.instantiate())	
	
func _show_defeat_ui():
	clean_up()
	$Music.stream = DEFEAT_AUDIO
	$Music.play() 
	add_child(DefeatGUI.instantiate())	
	
func clean_up():
	# set back to 1 in case user change game speed
	Engine.time_scale = 1
	$Camera2D.allow_user_input_camera_movement(false)
	
	$Gui.queue_free()
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, -70)	
	# victory/defeat music is a lil quiet
	$Music.volume_db = -5

func _exit_tree() -> void:
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, 0)
	
