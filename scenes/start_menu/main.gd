extends Control


func _ready():
	$ColorRect.visible = true
	$AnimationPlayer.play("fade in")
	await $AnimationPlayer.animation_finished
	
func _on_nut_bat_dau_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_nut_thoat_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().quit()


func _on_nut_huong_dan_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/instruction/instruction.tscn")
