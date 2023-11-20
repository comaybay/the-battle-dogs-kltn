extends Node

# preloaded audio
const BUTTON_PRESSED_AUDIO: AudioStream = preload("res://resources/sound/button_pressed.mp3")

## contain players and related data like tween node and playback position 
var _music_players: Dictionary = {} 
var _in_battle_sfx_players: Dictionary = {} 
var _current_music: AudioStream
## get currently playing music
func get_current_music() -> AudioStream: return _current_music

func _ready() -> void:
	process_mode =  PROCESS_MODE_ALWAYS
		
	var sound_fx_idx = AudioServer.get_bus_index("SoundFX")
	var music_idx = AudioServer.get_bus_index("Music")
	AudioServer.playback_speed_scale
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

func _create_music_player_data(audio: AudioStream) -> Dictionary:
	var music_player := _create_music_audio_player(audio) 
	add_child(music_player)
	return {
		"tween": create_tween(),
		"player": music_player,
		"playback_position": 0.0
	}

func _create_music_audio_player(audio: AudioStream) -> AudioStreamPlayer:
	var music_player := AudioStreamPlayer.new()
	music_player.stream = audio
	music_player.bus = "Music"
	return music_player
	
func _create_sfx_audio_player(audio: AudioStream) -> AudioStreamPlayer:
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SoundFX"
	sfx_player.stream = audio
	return sfx_player

func play_sfx(audio_stream: AudioStream, pitch_scale: float = 1.0):
	var sfx_player = _create_sfx_audio_player(audio_stream)
	sfx_player.pitch_scale = pitch_scale
	add_child(sfx_player)
	sfx_player.play()
	
	await sfx_player.finished
	sfx_player.queue_free()
	
func play_music(audio_stream: AudioStream, resume: bool = false, with_transition: bool = false):
	if not _music_players.has(audio_stream.resource_path):
		_music_players[audio_stream.resource_path] = _create_music_player_data(audio_stream)
	
	_current_music = audio_stream
	
	var music_data: Dictionary = _music_players[audio_stream.resource_path]
	var music_player: AudioStreamPlayer = music_data['player']
			
	var tween: Tween = music_data['tween']
	
	if not with_transition:
		tween.kill()
	else:		
		tween.pause()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(music_player, "volume_db", 0, 0.25)
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
	
func stop_music(audio_stream: AudioStream, with_transition: bool = false, remove_when_done: bool = false, stop_duration: float = 0.5):
	if audio_stream == null:
		return
	
	if audio_stream.resource_path == _current_music.resource_path:
		_current_music = null
		
	var music_data: Dictionary = _music_players[audio_stream.resource_path]
	var music_player: AudioStreamPlayer = music_data['player']
	var tween: Tween = music_data['tween']
	
	tween.pause()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CIRC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(music_player, "volume_db", -80, stop_duration)
	music_data['tween'] = tween
	
	if remove_when_done:
		_music_players.erase(audio_stream.resource_path)
		
	await tween.finished
	
	## if is removed
	if music_player == null:
		return
			
	if remove_when_done:
		music_player.stop()	
		music_player.queue_free()
	else:
		music_data['playback_position'] = music_player.get_playback_position()
		music_player.stop()	

func stop_current_music(with_transition: bool = false, remove_when_done: bool = false, stop_duration: float = 0.5):
	if get_current_music() != null:
		stop_music(get_current_music(), with_transition, remove_when_done, stop_duration)
	
## remove music data from memory (this includes playback position and audio player).
## only call this method when music is already stop
func remove_music(audio_stream: AudioStream) -> void:
	_music_players[audio_stream.resource_path]['player'].queue_free()
	_music_players.erase(audio_stream.resource_path)

func remove_all_music() -> void:
	for music_data in _music_players.values():
		music_data['player'].queue_free()
		
	_music_players.clear()

func get_random_pitch_scale() -> float:
	return randf_range(0.85, 1.15)

func _create_in_battle_sfx() -> AudioStreamPlayer:
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "InBattleFX"
	return sfx_player

func add_in_battle_sfx(audio_stream: AudioStream, max_polyphony: int = 1) -> void:
	if has_in_battle_sfx(audio_stream):
		var sfx_player: AudioStreamPlayer = _in_battle_sfx_players[audio_stream.resource_path]
		sfx_player.max_polyphony = max_polyphony
		return
		
	var sfx_player := _create_in_battle_sfx()
	sfx_player.stream = audio_stream
	sfx_player.max_polyphony = max_polyphony
	add_child(sfx_player)
	
	_in_battle_sfx_players[audio_stream.resource_path] = sfx_player

func has_in_battle_sfx(audio_stream: AudioStream) -> bool:
	return _in_battle_sfx_players.has(audio_stream.resource_path)
	
## Play an in battle sfx, this is good when the sfx is play multiple times quickly. [br]
## Require to add a sfx player to scene via the add_in_battle_sfx() function before using this method.
func play_in_battle_sfx(audio_stream: AudioStream, pitch_scale: float = 1.0) -> void:
	var sfx_player: AudioStreamPlayer = _in_battle_sfx_players[audio_stream.resource_path]
	sfx_player.pitch_scale = pitch_scale
	sfx_player.play()

## Remove sfx when it is no longer needed
func remove_in_battle_sfx(audio_stream: AudioStream) -> void:
	_in_battle_sfx_players[audio_stream.resource_path].queue_free()
	_in_battle_sfx_players.erase(audio_stream.resource_path)

func remove_all_in_battle_sfx() -> void:
	for audio_player in _in_battle_sfx_players.values():
		audio_player.queue_free()
		
	_in_battle_sfx_players.clear()

## Play a in battle sfx and then discard it, good for one time only sfx
func play_and_remove_in_battle_sfx(audio_stream: AudioStream, pitch_scale: float = 1.0) -> void:
	var sfx_player := _create_in_battle_sfx()
	sfx_player.stream = audio_stream
	sfx_player.pitch_scale = pitch_scale
	add_child(sfx_player)
	sfx_player.play()
	
	await sfx_player.finished
	sfx_player.queue_free()
	
