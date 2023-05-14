extends Control 

var game_data
func _ready():
	game_data = Data.save_data	

func _on_nut_tan_cong_pressed():
	get_tree().change_scene_to_file("res://scenes/battlefield/battlefield.tscn")
	
func _on_doi_doi_hinh_pressed():
	get_tree().change_scene_to_file("res://scenes/selectCharacter/selectCharacter.tscn")

func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")

func _on_level_pressed():
	pass # Replace with function body.

func _exit_tree() -> void:
	Data.save()
