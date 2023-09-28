extends Control

func _ready() -> void:
	%ButtonEnglish.mouse_entered.connect(func(): TranslationServer.set_locale("en"))
	%ButtonVietnamese.mouse_entered.connect(func(): TranslationServer.set_locale("vi"))
	
	%ButtonEnglish.pressed.connect(
		func():
			AudioPlayer.play_button_pressed_audio()
			set_language_preference("en")
			show_fullscreen_preference()
			
	)

	%ButtonVietnamese.pressed.connect(
		func():
			AudioPlayer.play_button_pressed_audio()
			set_language_preference("vi")
			show_fullscreen_preference()
	)
	
	%FullscreenYes.pressed.connect(
		func():
			%YesSound.play()
			set_fullscreen_preference(true)
			show_tutorial_preference()
	)
	
	%FullscreenNo.pressed.connect(
		func():
			AudioPlayer.play_button_pressed_audio()
			set_fullscreen_preference(false)
			show_tutorial_preference()
	)
	
	%TutorialYes.pressed.connect(
		func():
			%YesSound.play()
			$AnimationPlayer.play("dog_jump_up")
			await $AnimationPlayer.animation_finished
			get_tree().change_scene_to_file("res://scenes/start_menu/Intro.tscn")
	)
	
	%TutorialNo.pressed.connect(
		func():
			AudioPlayer.play_button_pressed_audio()
			choose_skip_tutorial()
			$AnimationPlayer.play("dog_jump_off")
			await $AnimationPlayer.animation_finished
			get_tree().change_scene_to_file("res://scenes/start_menu/Intro.tscn")
	)

func set_language_preference(language_code: String):
	Data.game_language = language_code
	Data.save()
	TranslationServer.set_locale(language_code) 

func set_fullscreen_preference(state: bool):
	Data.fullscreen = state
	GlobalControl.set_fullscreen(state)
	Data.save()
	
func show_fullscreen_preference():
	%LanguagePreference.hide()
	%FullscreenPreference.show()	
	
func show_tutorial_preference():
	%FullscreenPreference.hide()	
	%TutorialPreference.show()

func choose_skip_tutorial():
	for key in Data.save_data["tutorial"]:
		Data.save_data["tutorial"][key] = true
