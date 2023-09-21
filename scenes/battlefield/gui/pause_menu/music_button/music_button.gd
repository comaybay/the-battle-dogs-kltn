extends TextureButton

var is_mute: bool

func _ready() -> void:
	is_mute = Data.mute_music
	$AnimationPlayer.play("inactive" if is_mute else "active")
	pressed.connect(
		func(): 
			AudioPlayer.play_button_pressed_audio()
			set_mute(!is_mute)
	)

func set_mute(state: bool) -> void:
	is_mute = state 
	$AnimationPlayer.play("inactive" if is_mute else "active")
	Data.mute_music = is_mute
	Data.save()
