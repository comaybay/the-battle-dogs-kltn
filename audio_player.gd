extends Node

const BUTTON_PRESSED_AUDIO: AudioStream = preload("res://resources/sound/nhấn nút.mp3")

var button_pressed: AudioStreamPlayer
var music: AudioStreamPlayer

func _ready() -> void:
	button_pressed = AudioStreamPlayer.new()
	button_pressed.bus = "SoundFX"
	button_pressed.stream = BUTTON_PRESSED_AUDIO
	
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	
	var sound_fx_idx = AudioServer.get_bus_index("SoundFX")
	var music_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(sound_fx_idx, Data.sound_fx_volume - 100)
	AudioServer.set_bus_volume_db(music_idx, Data.music_volume - 100)
	Data.sound_fx_volume_changed.connect(
		func(value: float): 
			AudioServer.set_bus_volume_db(sound_fx_idx, value - 100)
	)
	Data.music_volume_changed.connect(
		func(value: float): 
			AudioServer.set_bus_volume_db(music_idx, value - 100)
	)
	
	add_child(button_pressed)
	add_child(music)

func play_button_pressed_audio():
	button_pressed.play()
