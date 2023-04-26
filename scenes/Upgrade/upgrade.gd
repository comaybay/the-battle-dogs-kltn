extends Control

const ListItem = preload("res://scenes/Upgrade/box.tscn")

var upgrade_data 
var game_data
var index = 0 

var Box : Node
func addItem(value):
	Box = $Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer
	
	var item = ListItem.instantiate()
	index += 1
	item.get_node("Button/Number").text = str(index)
	item.get_node("Button/TextureRect").texture = load(value)
	
	$Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.add_child(item)

func _ready():
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.money)
	#$Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer/Box/TextureRect.texture = load("res://resources/images/Screenshot (5).png")
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/upgrade.json", FileAccess.READ)
	upgrade_data = JSON.parse_string(file2.get_as_text())
	file2.close()	
	
	#var group = $Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.get_children()
	for i in upgrade_data["detail"].size() :
		print(upgrade_data["detail"][i]['path'])
		addItem(upgrade_data["detail"][i]['path'])
		




func _on_nut_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	print("add")
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
