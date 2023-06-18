extends TextureButton

var is_active: bool

func _ready() -> void:
	is_active = Data.sound_fx_volume > 0
	$AnimationPlayer.play("active" if is_active else "inactive")
	pressed.connect(
		func(): 
			AudioPlayer.play_button_pressed_audio()
			set_active(!is_active)
	)

func set_active(active: bool) -> void:
	is_active = active 
	$AnimationPlayer.play("active" if active else "inactive")
	Data.sound_fx_volume = 80 if active else 0
	Data.save()