extends Control


func _ready():
	$AnimationPlayer.play("fade in")
	await get_tree().create_timer(2).timeout
	$ColorRect.visible = false
	
func _on_nut_bat_dau_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_nut_thoat_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().quit()


func _on_nut_huong_dan_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/instruction/instruction.tscn")
