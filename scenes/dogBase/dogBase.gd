extends Control

func _on_nut_vien_chinh_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

func _on_nut_nang_cap_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/Upgrade/upgrade.tscn")

func _on_nut_cua_hang_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/store/store.tscn")
