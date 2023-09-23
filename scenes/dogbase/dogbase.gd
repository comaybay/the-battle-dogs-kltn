extends Control

var TutorialDogScene: PackedScene = preload("res://scenes/dogbase/dogbase_tutorial_dog/dogbase_tutorial_dog.tscn")

func _ready() -> void:
	AudioPlayer.resume_dogbase_music()
	
	if Data.has_done_battlefield_basics_tutorial and not Data.has_done_dogbase_tutorial:
		var canvas = CanvasLayer.new()
		get_parent().add_child.call_deferred(canvas)
		var tutorial_dog = TutorialDogScene.instantiate()
		canvas.add_child.call_deferred(tutorial_dog)
		canvas.tree_exited.connect(func(): canvas.queue_free())
	
	if not Data.has_done_battlefield_basics_tutorial:
		$BenTrai/NutNangCap.disabled = true
	
func _exit_tree() -> void:
	AudioPlayer.pause_dogbase_music()

func _on_nut_vien_chinh_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

func _on_nut_nang_cap_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/upgrade/upgrade.tscn")

func _on_nut_cua_hang_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/store/store.tscn")
