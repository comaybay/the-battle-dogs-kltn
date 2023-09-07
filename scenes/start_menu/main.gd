extends Control

const MAIN_THEME_AUDIO: AudioStream = preload("res://resources/sound/music/main_theme.mp3")
const SettingsScene: PackedScene = preload("res://scenes/settings/settings.tscn")
const CreditsScene: PackedScene = preload("res://scenes/credits/credits.tscn")

var _settings: Settings = null
var _credits: Credits = null

func _ready():
	if not AudioPlayer.custom_music.playing:
		AudioPlayer.play_custom_music(MAIN_THEME_AUDIO)
	
	$AnimationPlayer.play("ready")
	await $AnimationPlayer.animation_finished
	
	%SettingsButton.pressed.connect(_go_to_settings)
	%CreditButton.pressed.connect(_go_to_credits)
	
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

func _go_to_credits():
	AudioPlayer.play_button_pressed_audio()
	
	if (_credits == null):
		_credits = _create_credit()
		get_parent().add_child(_credits)
		
	self.hide()
	_credits.show()
	
func _create_credit() -> Credits:
	var credits: Credits = CreditsScene.instantiate()
	
	credits.goback_pressed.connect(func(): 
		self.show()
		credits.hide()
	)
	
	return credits
	
func _go_to_settings():
	AudioPlayer.play_button_pressed_audio()
	
	if (_settings == null):
		_settings = _create_settings()	
		get_parent().add_child(_settings)
		
	self.hide()
	_settings.show()

func _create_settings() -> Settings:
	var settings: Settings = SettingsScene.instantiate()
	
	settings.goback_pressed.connect(func(): 
		self.show()
		settings.hide()
	)
	
	return settings
