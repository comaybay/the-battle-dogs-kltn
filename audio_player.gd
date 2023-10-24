extends Node

const BUTTON_PRESSED_AUDIO: AudioStream = preload("res://resources/sound/button_pressed.mp3")
const LEVEL_SELECTED_AUDIO: AudioStream = preload("res://resources/sound/level_selected.wav")
const DOG_BASE_THEME_AUDIO: AudioStream = preload("res://resources/sound/music/dog_base_theme.mp3")

var _playback_position: float = 0
var _music_stopping: bool = false
var _music_starting: bool = false
var _tween: Tween

var custom_sound: AudioStreamPlayer
var button_pressed: AudioStreamPlayer
var custom_music: AudioStreamPlayer
var dogbase_music: AudioStreamPlayer
var level_selected: AudioStreamPlayer

func _create_audio_sfx(audio: AudioStream):
	var audio_player = AudioStreamPlayer.new()
	audio_player.bus = "SoundFX"
	audio_player.stream = audio
	add_child(audio_player)
	return audio_player
	
func _ready() -> void:
	process_mode =  PROCESS_MODE_ALWAYS
	custom_sound = _create_audio_sfx(null)
	button_pressed = _create_audio_sfx(BUTTON_PRESSED_AUDIO)
	level_selected = _create_audio_sfx(LEVEL_SELECTED_AUDIO)
		
	dogbase_music = AudioStreamPlayer.new()
	dogbase_music.stream = DOG_BASE_THEME_AUDIO
	dogbase_music.bus = "Music"
	dogbase_music.volume_db = -7
	add_child(dogbase_music)
	
	custom_music = dogbase_music.duplicate()
	add_child(custom_music)
	
	var sound_fx_idx = AudioServer.get_bus_index("SoundFX")
	var music_idx = AudioServer.get_bus_index("Music")
	
	Data.sound_fx_volume_changed.connect(
		func(value: float): 
			AudioServer.set_bus_volume_db(sound_fx_idx, linear_to_db(value / 100.0))
	)
	Data.music_volume_changed.connect(
		func(value: float): 
			AudioServer.set_bus_volume_db(music_idx, linear_to_db(value / 100.0))
	)
	Data.mute_music_changed.connect(
		func(mute: bool): 
			var value: float = 0 if mute else Data.music_volume 
			AudioServer.set_bus_volume_db(music_idx, linear_to_db(value / 100.0))
	)
	Data.mute_sound_fx_changed.connect(
		func(mute: bool): 
			var value: float = 0 if mute else Data.sound_fx_volume
			AudioServer.set_bus_volume_db(sound_fx_idx, linear_to_db(value / 100.0))
	)

func play_button_pressed_audio():
	button_pressed.play()

func play_level_selected_audio():
	level_selected.play()
	
func pause_dogbase_music():
	_music_stopping = true
	_tween = create_tween()
	_tween.tween_property(dogbase_music, "volume_db", -70, 0.7)
	
	_tween.finished.connect(_handle_finished, CONNECT_ONE_SHOT)
	
func resume_dogbase_music():
	if dogbase_music.playing and _music_stopping == false:
		return
		
	_music_starting = true
	if _music_stopping:
		_tween.stop()
	else:
		dogbase_music.play(_playback_position)
	
	_tween = create_tween()
	_tween.tween_property(dogbase_music, "volume_db", -7, 0.4)
	
	await _tween.finished 
	_music_starting = false
	
func _handle_finished():
	_music_stopping = false
	if _music_starting == false:
		_playback_position = dogbase_music.get_playback_position()
		dogbase_music.stop()

func play_custom_sound(audio_stream: AudioStream, pitch_scale: float = 1.0):
	custom_sound.stream = audio_stream
	custom_sound.pitch_scale = pitch_scale
	custom_sound.play()

func play_custom_music(audio_stream: AudioStream):
	custom_music.stream = audio_stream
	custom_music.play()
	
func stop_custom_music():
	custom_music.stop()
	
func get_random_pitch_scale() -> float:
	return randf_range(0.85, 1.15)
