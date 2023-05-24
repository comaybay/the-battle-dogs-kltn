extends AudioStreamPlayer

const BUTTON_PRESSED_AUDIO: AudioStream = preload("res://resources/sound/nhấn nút.mp3")

func play_button_pressed_audio():
	stream = BUTTON_PRESSED_AUDIO
	play()
	
