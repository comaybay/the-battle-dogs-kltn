extends TextureButton

var is_active: bool

func _ready() -> void:
	$AnimationPlayer.play("default")
	pressed.connect(func(): AudioPlayer.play_button_pressed_audio())
	button_down.connect(func(): $AnimationPlayer.play("hold"))
	button_up.connect(func(): $AnimationPlayer.play("default"))
