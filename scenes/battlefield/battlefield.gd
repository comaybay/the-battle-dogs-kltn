class_name Battlefield extends Node2D

var VictoryGUI: PackedScene = preload("res://scenes/battlefield/victory_gui/victory_gui.tscn")
var DefeatGUI: PackedScene = preload("res://scenes/battlefield/defeat_gui/defeat_gui.tscn")

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")

var stage_width: int
var inbattle_sfx_idx: int

var boss_audio: AudioStream

func _enter_tree() -> void:
	var battlefield_data = InBattle.load_battlefield_data()
	InBattle.reset()
	stage_width = battlefield_data['stage_width']
	
func _ready() -> void:	
	inbattle_sfx_idx = AudioServer.get_bus_index("InBattleFX")
	
	$Music.stream = load("res://resources/sound/music/%s.mp3" % InBattle.battlefield_data['music'])
	$Music.play()
	
	if InBattle.battlefield_data.get('boss_music') != null:
		boss_audio = load("res://resources/sound/music/%s.mp3" % InBattle.battlefield_data['boss_music'])
	
	var half_viewport_size = get_viewport().size / 2
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % InBattle.battlefield_data['theme'])
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width
	
	$CatTower.position.x = stage_width - 500;
	$CatTower.position.y = -50
	$DogTower.position.x = 500
	$DogTower.position.y = -50
	
	$Land.position.x = stage_width / 2.0
	
	$Camera2D.position = Vector2(0, -half_viewport_size.y)

	$CatTower.boss_appeared.connect(_on_boss_appeared)
	$CatTower.zero_health.connect(_show_win_ui, CONNECT_ONE_SHOT)
	$DogTower.zero_health.connect(_show_defeat_ui, CONNECT_ONE_SHOT)

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
	$Camera2D.disable_camera_movement()
	$Gui.queue_free()
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, -70)	
	# victory/defeat music is a lil quiet
	$Music.volume_db = -5

func _exit_tree() -> void:
	AudioServer.set_bus_volume_db(inbattle_sfx_idx, 0)

func _on_boss_appeared() -> void:
	$BossDrum.play()
	
	if boss_audio != null and $Music.stream != boss_audio:
		$Music.stop()
		$Music.stream = boss_audio 
		await $BossDrum.finished
		$Music.play()

