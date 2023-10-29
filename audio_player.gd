extends Node

# preloaded audio
const BUTTON_PRESSED_AUDIO: AudioStream = preload("res://resources/sound/button_pressed.mp3")

enum AudioType { MUSIC, SFX }
const MUSIC_DEFAULT_DB: float = -7.0
const SFX_DEFAULT_DB: float = 0.0

## contain players and related data like tween node and playback position 
var _music_players: Dictionary = {} 
var _current_music: AudioStream
## get currently playing music
func get_current_music() -> AudioStream: return _current_music

func _ready() -> void:
	process_mode =  PROCESS_MODE_ALWAYS
		
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

func _create_audio_player_data(audio: AudioStream, type: AudioType) -> Dictionary:
	return {
		"tween": create_tween(),
		"player": ( 
			_create_music_audio_plyaer(audio) if type == AudioType.MUSIC 
			else _create_sfx_audio_player(audio)
		),
		"playback_position": 0.0
	}

func _create_music_audio_plyaer(audio: AudioStream) -> AudioStreamPlayer:
	var music_player := AudioStreamPlayer.new()
	music_player.stream = audio
	music_player.bus = "Music"
	music_player.volume_db = MUSIC_DEFAULT_DB
	add_child(music_player)
	return music_player
	
func _create_sfx_audio_player(audio: AudioStream) -> AudioStreamPlayer:
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SoundFX"
	sfx_player.stream = audio
	sfx_player.volume_db = SFX_DEFAULT_DB
	add_child(sfx_player)
	return sfx_player
	
func play_sfx(audio_stream: AudioStream, pitch_scale: float = 1.0):
	var sfx_player = _create_sfx_audio_player(audio_stream)
	sfx_player.pitch_scale = pitch_scale
	sfx_player.play()
	
	await sfx_player.finished
	sfx_player.queue_free()

func play_music(audio_stream: AudioStream, resume: bool = false, with_transition: bool = false):
	if not _music_players.has(audio_stream.resource_path):
		_music_players[audio_stream.resource_path] = _create_audio_player_data(audio_stream, AudioType.MUSIC)
	
	_current_music = audio_stream
	
	var music_data: Dictionary = _music_players[audio_stream.resource_path]
	var music_player: AudioStreamPlayer = music_data['player']
			
	var tween: Tween = music_data['tween']
	
	if not with_transition:
		music_player.volume_db = MUSIC_DEFAULT_DB
		tween.kill()
	else:		
		tween.pause()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(music_player, "volume_db", -7, 0.5)
		music_data['tween'] = tween
	
	# music is not fully stopped yet (still being in fade out transition)
	if resume and music_player.playing:
		return
	
	if resume:
		music_player.play(music_data['playback_position'])
	else:
		music_player.play()
		
	music_player.finished.connect(
		func():
			_current_music = null
			remove_music(audio_stream)
	, CONNECT_ONE_SHOT)
	
func stop_music(audio_stream: AudioStream, with_transition: bool = false, remove_data: bool = false):
	if audio_stream.resource_path == _current_music.resource_path:
		_current_music = null
		
	var music_data: Dictionary = _music_players[audio_stream.resource_path]
	var music_player: AudioStreamPlayer = music_data['player']
	var tween: Tween = music_data['tween']

	if remove_data:
		remove_music(audio_stream)
	
	tween.pause()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(music_player, "volume_db", -80, 0.5)
	music_data['tween'] = tween
	
	await tween.finished
	
	# data might be removed  
	if _music_players.has(audio_stream.resource_path):
		music_data['playback_position'] = music_player.get_playback_position()
	
	music_player.stop()	
	
## remove music data from memory (this includes playback position)
func remove_music(audio_stream: AudioStream) -> void:
	_music_players.erase(audio_stream.resource_path)

func remove_all_music() -> void:
	_music_players.clear()

func get_random_pitch_scale() -> float:
	return randf_range(0.85, 1.15)
