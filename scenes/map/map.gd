extends Control 

var game_data
func _ready():
	var file = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file.get_as_text())
	file.close()


func _process(delta):	
	pass
	
func _on_nut_tan_cong_pressed():
	print(Data.level_select)

	
func _on_doi_doi_hinh_pressed():
	get_tree().change_scene_to_file("res://scenes/selectCharacter/selectCharacter.tscn")

func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")



func _on_level_pressed():
	pass # Replace with function body.
