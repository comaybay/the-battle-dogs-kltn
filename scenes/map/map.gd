extends Control 

func _ready():
	Data.money -= 100
	print(Data.money)
	pass
		

func _process(delta):	
	pass
	
func _on_nut_tan_cong_pressed():
	print(Data.level_pass)
	pass

	
func _on_doi_doi_hinh_pressed():
	get_tree().change_scene_to_file("res://scenes/selectCharacter/selectCharacter.tscn")

func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")



func _on_level_pressed():
	pass # Replace with function body.
