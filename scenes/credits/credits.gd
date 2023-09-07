class_name Credits extends Control

signal goback_pressed

func _ready() -> void:
	%GoBackButton.pressed.connect(func(): 
		AudioPlayer.play_button_pressed_audio()
		goback_pressed.emit()
	)
