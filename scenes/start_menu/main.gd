extends Control

const MAIN_THEME_AUDIO: AudioStream = preload("res://resources/sound/music/main_theme.mp3")

func _ready():
	if not AudioPlayer.custom_music.playing:
		AudioPlayer.play_custom_music(MAIN_THEME_AUDIO)
	
	$AnimationPlayer.play("ready")
	await $AnimationPlayer.animation_finished
	
func _on_nut_bat_dau_pressed():
	AudioPlayer.stop_custom_music()
	
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")


func _on_nut_thoat_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().quit()


func _on_nut_huong_dan_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/instruction/instruction.tscn")
