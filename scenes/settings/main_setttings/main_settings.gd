class_name MainSettings extends Panel
signal goback_pressed
signal keybinding_settings_pressed

const DEFAULT_MUSIC_VOLUME: int = 60
const DEFAULT_SFX_VOLUME: int = 50

func _ready() -> void:
	%MusicSlider.value = Data.music_volume
	%MusicSlider.value_changed.connect(func(value: float) -> void: 
		Data.music_volume = value
		%MusicButton.set_mute(value == 0)
	)
	
	%SFXSlider.value = Data.sound_fx_volume
	%SFXSlider.value_changed.connect(func(value: float) -> void: 
		Data.sound_fx_volume = value
		%SFXButton.set_mute(value == 0)
	)
	
	%SFXSlider.drag_ended.connect(func(_value_changed: bool) -> void:
		AudioPlayer.play_button_pressed_audio()
	)

	Data.mute_music_changed.connect(on_mute_music_changed)
	Data.mute_sound_fx_changed.connect(on_mute_sfx_changed)	
	
	%KeyBindingSettingsButton.pressed.connect(func() -> void:
		AudioPlayer.play_button_pressed_audio()
		keybinding_settings_pressed.emit()
	)
	
	%GoBackButton.pressed.connect(func() -> void:
		AudioPlayer.play_button_pressed_audio()
		goback_pressed.emit()
	)

func _exit_tree() -> void:
	Data.mute_music_changed.disconnect(on_mute_music_changed)
	Data.mute_sound_fx_changed.disconnect(on_mute_sfx_changed)	
	
func on_mute_music_changed(mute: bool) -> void:
	if mute:
		%MusicSlider.set_value_no_signal(0)
	elif Data.music_volume > 0:
		%MusicSlider.set_value_no_signal(Data.music_volume) 
	else:
		%MusicSlider.value = DEFAULT_MUSIC_VOLUME
		
func on_mute_sfx_changed(mute: bool) -> void:
		if mute:
			%SFXSlider.set_value_no_signal(0)
		elif Data.sound_fx_volume > 0:
			%SFXSlider.set_value_no_signal(Data.sound_fx_volume) 
		else:
			%SFXSlider.value = DEFAULT_SFX_VOLUME
