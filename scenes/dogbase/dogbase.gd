extends Control
const DOG_BASE_THEME_AUDIO: AudioStream = preload("res://resources/sound/music/dog_base_theme.mp3")

var TutorialDogScene: PackedScene = preload("res://scenes/dogbase/dogbase_tutorial_dog/dogbase_tutorial_dog.tscn")

func _ready() -> void:
	if Data.save_data['chapters']['the_battle_dogs_rising']['completed']:
		%SelectChapterIcon.position.x = -%ExpeditionButton.size.x - (%SelectChapterIcon.size.x * 0.5)
	else:
		%ExpeditionButton.theme_type_variation = ""
		%ExpeditionButton.alignment = HORIZONTAL_ALIGNMENT_CENTER
		%SelectChapterIcon.get_parent().queue_free()
		
	AudioPlayer.play_music(DOG_BASE_THEME_AUDIO, true, true)
	
	var on_go_back_pressed = func():
		var main_gui: = get_tree().current_scene as MainGUI
		main_gui.get_go_back_button().pressed.connect(func():
			AudioPlayer.stop_music(DOG_BASE_THEME_AUDIO, true, true)
		)
		
	on_go_back_pressed.call_deferred()
	
	if 	(
		not Data.has_done_dogbase_tutorial or
		(Data.has_done_battlefield_basics_tutorial and not Data.has_done_dogbase_after_battlefield_tutorial)
	):
		var canvas = CanvasLayer.new()
		get_parent().add_child.call_deferred(canvas)
		var tutorial_dog = TutorialDogScene.instantiate()
		canvas.add_child.call_deferred(tutorial_dog)
		canvas.tree_exited.connect(func(): canvas.queue_free())
	
	if not Data.has_done_battlefield_basics_tutorial:
		$BenTrai/NutNangCap.disabled = true
	


func _on_nut_vien_chinh_pressed():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

func _on_nut_nang_cap_pressed():
	AudioPlayer.stop_music(DOG_BASE_THEME_AUDIO, true)
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/upgrade/upgrade.tscn")

func _on_nut_cua_hang_pressed():
	AudioPlayer.stop_music(DOG_BASE_THEME_AUDIO, true)
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/store/store.tscn")

@onready var ranking = preload("res://addons/silent_wolf/Scores/Leaderboard.tscn")
func _on_nut_xep_hang_pressed():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)	
	get_tree().change_scene_to_packed(ranking)
