class_name OnlineBattlefield extends Node2D

var VictoryGUI: PackedScene = preload("res://scenes/battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefield/defeat_gui/defeat_gui.tscn")
var TutorialDogScene: PackedScene = preload("res://scenes/battlefield/battlefield_tutorial_dog/battlefield_tutorial_dog.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")

## margin for position.x of cat tower and dog tower
const TOWER_MARGIN: int = 700

var stage_width: int
var inbattle_sfx_idx: int

var _player_dog_tower: DogTower

func _enter_tree() -> void:
	InBattle.reset()
	stage_width = int(SteamUser.get_lobby_data("stage_width"))
	
func _ready() -> void:
	$Camera2D.setup(($Gui as BattleGUI).camera_control_buttons)
	
	inbattle_sfx_idx = AudioServer.get_bus_index("InBattleFX")
	
	$Music.stream = load("res://resources/sound/music/%s.mp3" % SteamUser.get_lobby_data("music"))
	$Music.play()
	
	var half_viewport_size = get_viewport().size / 2
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % SteamUser.get_lobby_data("theme"))
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width
	
	_player_dog_tower = $DogTower1
	var opponent_dog_tower = $DogTower2
	$Camera2D.position = Vector2(0, -half_viewport_size.y)
	
	if SteamUser.lobby_members[0] != SteamUser.lobby_id:
		_player_dog_tower = $DogTower2
		opponent_dog_tower = $DogTower1
		$Camera2D.position = Vector2(stage_width, -half_viewport_size.y)
	
	$DogTower1.position.x = TOWER_MARGIN
	$DogTower1.position.y = -50
	
	$DogTower2.position.x = stage_width - TOWER_MARGIN;
	$DogTower2.position.y = -50
	
	$Land.position.x = stage_width / 2.0

	_player_dog_tower.zero_health.connect(_show_win_ui, CONNECT_ONE_SHOT)
	opponent_dog_tower.zero_health.connect(_show_defeat_ui, CONNECT_ONE_SHOT)

func get_dog_tower() -> DogTower:
	return $DogTower1 if SteamUser.lobby_members[0] == SteamUser.STEAM_ID else $DogTower2

func _process(delta: float) -> void:
	InBattle.update(delta)
	
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
