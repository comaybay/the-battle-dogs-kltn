class_name Battlefield extends BaseBattlefield

var VictoryGUI: PackedScene = preload("res://scenes/battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefield/defeat_gui/defeat_gui.tscn")
var TutorialDogScene: PackedScene = preload("res://scenes/battlefield/battlefield_tutorial_dog/battlefield_tutorial_dog.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")

var inbattle_sfx_idx: int
var boss_audio: AudioStream
var _player_data: BattlefieldPlayerData

var _battlefield_data: Dictionary
## get battlefield data from .json file
func get_battlefield_data() -> Dictionary: return _battlefield_data
	
var _tutorial_dog: BattlefieldTutorialDog = null

func _enter_tree() -> void:
	_battlefield_data = _load_battlefield_data()
	_player_data = BattlefieldPlayerData.new()

func _load_battlefield_data() -> Dictionary:
	var file = FileAccess.open("res://resources/battlefield_data/%s.json" % Data.selected_battlefield_id, FileAccess.READ)
	var battlefield_data: Dictionary = JSON.parse_string(file.get_as_text())
	battlefield_data['stage_width'] += 300 * 2
	file.close()
	return battlefield_data	

func get_stage_width() -> int: return _battlefield_data['stage_width']

func get_player_data() -> BaseBattlefieldPlayerData: return _player_data

func get_theme() -> String: return _battlefield_data['theme']

func get_cat_power_scale() -> float:
	var scale = _battlefield_data.get('power_scale')
	return scale if scale != null else 1

func _ready() -> void:
	if (
		not Data.has_done_battlefield_basics_tutorial 
		or not Data.has_done_battlefield_boss_tutorial
		or not Data.has_done_battlefield_final_boss_tutorial
		or not Data.has_done_battlefield_rush
	):
		_tutorial_dog = TutorialDogScene.instantiate()
		_tutorial_dog.setup($CatTower, $DogTower, $Camera2D, $Gui)
		$Gui.add_child(_tutorial_dog)
	
	$Gui.setup($DogTower, _player_data)
	
	$Camera2D.setup(($Gui as BattleGUI).camera_control_buttons, get_stage_width())
	
	inbattle_sfx_idx = AudioServer.get_bus_index("InBattleFX")
	
	$Music.stream = load("res://resources/sound/music/%s.mp3" % _battlefield_data['music'])
	$Music.play()
	
	if _battlefield_data.get('boss_music') != null:
		boss_audio = load("res://resources/sound/music/%s.mp3" % _battlefield_data['boss_music'])
	
	var half_viewport_size: Vector2i = get_viewport().size / 2
	var stage_width := get_stage_width()
	
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % _battlefield_data['theme'])
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width
	
	$CatTower.position.x = stage_width - TOWER_MARGIN;
	$DogTower.position.x = TOWER_MARGIN
	
	$Land.position.x = stage_width / 2.0
	
	$Camera2D.position = Vector2(0, -half_viewport_size.y)

	$CatTower.boss_appeared.connect(_on_boss_appeared)
	$CatTower.zero_health.connect(_show_win_ui, CONNECT_ONE_SHOT)
	$DogTower.zero_health.connect(_show_defeat_ui, CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	_player_data.update(delta)
	
func _show_win_ui():
	clean_up()
	$Music.stream = VICTORY_AUDIO
	$Music.play() 
	add_child(VictoryGUI.instantiate())	
	
	# move the tutorial dog outside of gui
	if _tutorial_dog != null:
		_move_tutorial_dog()
	
func _show_defeat_ui():
	clean_up()
	$Music.stream = DEFEAT_AUDIO
	$Music.play() 
	add_child(DefeatGUI.instantiate())	
	
	# move the tutorial dog outside of gui
	if _tutorial_dog != null:
		_move_tutorial_dog()

func _move_tutorial_dog():
	var canvas_layer: = CanvasLayer.new()
	add_child(canvas_layer)
	_tutorial_dog.reparent(canvas_layer)

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

func _on_boss_appeared() -> void:
	var game_speed_button := ($Gui as BattleGUI).game_speed_button
	if game_speed_button.is_actived():
		game_speed_button.toggle_game_speed()
	
	$BossDrum.play()
	
	if boss_audio != null and $Music.stream != boss_audio:
		$Music.stop()
		$Music.stream = boss_audio 
		await $BossDrum.finished
		$Music.play()

