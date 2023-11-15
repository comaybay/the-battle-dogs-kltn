class_name IconButton extends TextureButton

var _activated := false

func _ready() -> void:
	button_down.connect(func():
		$AnimationPlayer.play("button_down")
	)
	button_up.connect(
		func(): set_activated(_activated) 
	)
	
	pressed.connect(func():
		set_activated(!_activated)
		AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	)

func set_activated(activated: bool) -> void:
	_activated = activated
	$AnimationPlayer.play("on" if activated else "off")
