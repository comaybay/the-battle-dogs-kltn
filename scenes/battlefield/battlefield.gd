class_name Battlefield extends BaseBattlefield

var VictoryGUI: PackedScene = preload("res://scenes/battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefield/defeat_gui/defeat_gui.tscn")
var TutorialDogScene: PackedScene = preload("res://scenes/battlefield/battlefield_tutorial_dog/battlefield_tutorial_dog.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")

var _boss_music: AudioStream
var _player_data: BattlefieldPlayerData
var time_batlle : float
var _battlefield_data: Dictionary

## get battlefield data from .json file
func get_battlefield_data() -> Dictionary: return _battlefield_data
	
var _tutorial_dog: BattlefieldTutorialDog = null

func _enter_tree() -> void:
	InBattle.in_p2p_battle = false
	InBattle.in_request_mode = false
	_battlefield_data = _load_battlefield_data()
	_player_data = BattlefieldPlayerData.new()

func _load_battlefield_data() -> Dictionary:
	
	var dir = "%s/stages/%s.json" % [
		Data.selected_chapter_dir_path,
		Data.selected_battlefield_id,
	]
	var file = FileAccess.open(dir, FileAccess.READ)
	var battlefield_data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	return battlefield_data	

func get_stage_width() -> int: return _battlefield_data['stage_width']

func get_player_data() -> BaseBattlefieldPlayerData: return _player_data

func get_theme() -> String: return _battlefield_data['theme']

func get_dog_tower() -> DogTower:
	return $DogTower
	
func get_cat_tower() -> CatTower:
	return $CatTower

func get_cat_power_scale() -> float:
	var scale = _battlefield_data.get('power_scale')
	return scale if scale != null else 1

func _ready() -> void:
	time_batlle = 0
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
	$store_gui.setup($DogTower, _player_data)
	var stage_width := get_stage_width()
	var stage_width_with_margin := stage_width + (TOWER_MARGIN * 2)
	
	$Camera2D.setup(($Gui as BattleGUI).camera_control_buttons, stage_width_with_margin, get_stage_height())
	
	AudioPlayer.play_music(load("res://resources/sound/music/%s.mp3" % _battlefield_data['music']))
	
	if _battlefield_data.get('boss_music') != null:
		_boss_music = load("res://resources/sound/music/%s.mp3" % _battlefield_data['boss_music'])
	
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % _battlefield_data['theme'])
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width_with_margin
	
	$DogTower.position.x = TOWER_MARGIN
	$CatTower.position.x = stage_width_with_margin - TOWER_MARGIN;

	$CatTower.boss_appeared.connect(_on_boss_appeared)
	$CatTower.zero_health.connect(_show_win_ui, CONNECT_ONE_SHOT)
	$DogTower.zero_health.connect(_show_defeat_ui, CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	_player_data.update(delta)
	
func _show_win_ui():
	$TimeBattle.stop()
	var get_time = int(Time.get_ticks_msec() / 1000)
	_clean_up()
	
	if (Data.use_sw_data == true) and (Data.passed_level == 13) :
		Data.victory_count += 1 
		SilentWolf.Scores.save_score(Data.save_data["user_name"],Data.victory_count, "victory_count")
		SilentWolf.sw_save_score_time(Data.save_data["user_name"], get_time,"fastest_time")

	var current_music = AudioPlayer.get_current_music()
	AudioPlayer.stop_music(current_music, true, true)
	AudioPlayer.play_music(VICTORY_AUDIO)
	add_child(VictoryGUI.instantiate())	

	# move the tutorial dog outside of gui
	if _tutorial_dog != null:
		_move_tutorial_dog()
	
func _show_defeat_ui():
	_clean_up()
	var current_music = AudioPlayer.get_current_music()
	AudioPlayer.stop_music(current_music, true, true)
	AudioPlayer.play_music(DEFEAT_AUDIO)
	add_child(DefeatGUI.instantiate())	
	
	# move the tutorial dog outside of gui
	if _tutorial_dog != null:
		_move_tutorial_dog()

func _move_tutorial_dog():
	var canvas_layer: = CanvasLayer.new()
	add_child(canvas_layer)
	_tutorial_dog.reparent(canvas_layer)

func _on_boss_appeared() -> void:
	var game_speed_button := ($Gui as BattleGUI).game_speed_button
	if game_speed_button.is_actived():
		game_speed_button.toggle_game_speed()
	
	$BossDrum.play()
	var current_music = AudioPlayer.get_current_music()
	if _boss_music != null and current_music != _boss_music:
		AudioPlayer.stop_music(current_music, false, true)
		await $BossDrum.finished
		AudioPlayer.play_music(_boss_music)

