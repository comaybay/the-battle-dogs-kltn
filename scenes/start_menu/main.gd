extends Control

const MAIN_THEME_AUDIO: AudioStream = preload("res://resources/sound/music/main_theme.mp3")

const SettingsScene: PackedScene = preload("res://scenes/settings/settings.tscn")

func _ready():
	if not AudioPlayer.custom_music.playing:
		AudioPlayer.play_custom_music(MAIN_THEME_AUDIO)
	
	$AnimationPlayer.play("ready")
	await $AnimationPlayer.animation_finished
	
	%SettingsButton.pressed.connect(_go_to_settings)
	
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

func _go_to_settings():
	var settings: Settings = SettingsScene.instantiate()

	self.hide()
	get_parent().add_child(settings)
	
	settings.goback_pressed.connect(func(): 
		self.show()
		settings.queue_free()			
	)
