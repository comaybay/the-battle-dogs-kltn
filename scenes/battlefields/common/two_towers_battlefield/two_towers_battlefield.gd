class_name Battlefield extends BaseBattlefield

var VictoryGUI: PackedScene = preload("res://scenes/battlefields/common/base_battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefields/common/base_battlefield/defeat_gui/defeat_gui.tscn")
var TutorialDogScene: PackedScene = preload("res://scenes/battlefields/common/base_battlefield/battlefield_tutorial_dog/battlefield_tutorial_dog.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")
var BOSS_DRUM: AudioStream = preload("res://resources/sound/battlefield/boss_drum.mp3") 

var _boss_music: AudioStream
var _player_data: BattlefieldPlayerData
var time_batlle : float
var _stage_data: Dictionary

@export var dog_tower: BaseDogTower
@export var cat_tower: CatTower
var _tutorial_dog: BattlefieldTutorialDog = null

func _init() -> void:
	InBattle.in_p2p_battle = false
	InBattle.in_request_mode = false
	_stage_data = InBattle.load_stage_data()
	_player_data = BattlefieldPlayerData.new()

func get_stage_width() -> int: return _stage_data['stage_width'] + TOWER_MARGIN * 2

func get_stage_height() -> int: 
	return land.get_land_bottom_y() - sky.position.y
	
func get_stage_rect() -> Rect2:
	return Rect2(0, sky.position.y, get_stage_width(), get_stage_height())

func get_player_data() -> BaseBattlefieldPlayerData: return _player_data

func get_dog_tower() -> DogTower:
	return dog_tower
	
func get_cat_tower() -> CatTower:
	return cat_tower

func get_cat_power_scale() -> float:
	return _stage_data.get('power_scale', 1.0)

func _ready() -> void:
	assert(dog_tower != null, "ERROR: dog tower not assigned in Battlefield")
	assert(cat_tower != null, "ERROR: cat tower not assigned in Battlefield")
	assert(land != null, "ERROR: land not assigned in Battlefield")
	
	time_batlle = 0
	if (
		not Data.has_done_battlefield_basics_tutorial 
		or not Data.has_done_battlefield_boss_tutorial
		or not Data.has_done_battlefield_final_boss_tutorial
		or not Data.has_done_battlefield_rush
	):
		_tutorial_dog = TutorialDogScene.instantiate()
		_tutorial_dog.setup(cat_tower, dog_tower, $Camera2D, $Gui)
		$Gui.add_child(_tutorial_dog)
	
	$Gui.setup(dog_tower, _player_data)
	$store_gui.setup(dog_tower, _player_data)
	
	$Camera2D.setup(($Gui as BattleGUI).camera_control_buttons, get_stage_rect())
	
	AudioPlayer.play_music(load("res://resources/sound/music/%s.mp3" % _stage_data['music']))
	
	if _stage_data.get('boss_music') != null:
		_boss_music = load("res://resources/sound/music/%s.mp3" % _stage_data['boss_music'])
		
	dog_tower.position.x = TOWER_MARGIN
	cat_tower.position.x = get_stage_width() - TOWER_MARGIN;

	dog_tower.zero_health.connect(_show_defeat_ui, CONNECT_ONE_SHOT)
	cat_tower.zero_health.connect(_show_win_ui, CONNECT_ONE_SHOT)
	cat_tower.boss_appeared.connect(_on_boss_appeared)

func _process(delta: float) -> void:
	_player_data.update(delta)
	
func _show_win_ui():
	$TimeBattle.stop()
	var get_time = int(Time.get_ticks_msec() / 1000)
	_clean_up()
	# need fix
	if (Data.use_sw_data == true) and (Data.passed_stage == 13) :
		Data.victory_count += 1 
		SilentWolf.sw_save_high_scores(Data.save_data["user_name"], "victory_count",1)
		SilentWolf.sw_save_score_time(Data.save_data["user_name"], get_time,"fastest_time")
		Data.save()
	
	AudioPlayer.stop_current_music(true, true)
	AudioPlayer.play_music(VICTORY_AUDIO)
	add_child(VictoryGUI.instantiate())	

	# move the tutorial dog outside of gui
	if _tutorial_dog != null:
		_move_tutorial_dog()
	
func _show_defeat_ui():
	_clean_up()
	AudioPlayer.stop_current_music(true, true)
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
	
	var current_music = AudioPlayer.get_current_music()
	if _boss_music != null and current_music != _boss_music:
		AudioPlayer.stop_music(current_music, false, true)
		await AudioPlayer.play_in_battle_sfx(BOSS_DRUM)
		AudioPlayer.play_music(_boss_music)
	else:
		AudioPlayer.play_in_battle_sfx(BOSS_DRUM)
