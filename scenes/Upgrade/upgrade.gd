extends Control

var upgrade_data 
var game_data
# Called when the node enters the scene tree for the first time.
func _ready():
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	var file2 = FileAccess.open("res://resources/game_data/upgrade.json", FileAccess.READ)
	upgrade_data = JSON.parse_string(file2.get_as_text())
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.money)
	
	file1.close()
	file2.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_nut_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
