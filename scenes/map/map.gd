extends Control 

var game_data
func _ready():
	game_data = Data.save_data	

func _on_nut_tan_cong_pressed():
	InBattle.battlefield_id = Data.selected_battlefield_id
	$Click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/battlefield/battlefield.tscn")
	
func _on_doi_doi_hinh_pressed():
	$Click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/selectCharacter/selectCharacter.tscn")

func _on_quay_lai_pressed():
	$Click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")

func _exit_tree() -> void:
	Data.save()
