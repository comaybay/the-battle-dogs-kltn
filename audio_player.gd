extends Node

const BUTTON_PRESSED_AUDIO: AudioStream = preload("res://resources/sound/button_pressed.mp3")
const LEVEL_SELECTED_AUDIO: AudioStream = preload("res://resources/sound/level_selected.wav")

var button_pressed: AudioStreamPlayer
var music: AudioStreamPlayer
var level_selected: AudioStreamPlayer

func _create_audio_sfx(audio: AudioStream):
	var audio_player = AudioStreamPlayer.new()
	audio_player.bus = "SoundFX"
	audio_player.stream = audio
	add_child(audio_player)
	return audio_player
	
func _ready() -> void:
	button_pressed = _create_audio_sfx(BUTTON_PRESSED_AUDIO)
	level_selected = _create_audio_sfx(LEVEL_SELECTED_AUDIO)
		
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
	
	
	add_child(music)

func play_button_pressed_audio():
	button_pressed.play()

func play_level_selected_audio():
	level_selected.play()
