@tool
extends MainGUI

func _on_go_back_pressed():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	hide()
