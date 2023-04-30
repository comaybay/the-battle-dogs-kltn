extends Control

const ListItem = preload("res://scenes/Upgrade/box.tscn")

var upgrade_data 
var game_data
var index = 0 
var select_index = 0
var detail_index = ""
var number_index = 0

func _ready():	
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/upgrade.json", FileAccess.READ)
	upgrade_data = JSON.parse_string(file2.get_as_text())
	file2.close()	
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.money)
	#var group = $Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.get_children()
	for i in upgrade_data["detail"].size() :
		#print(upgrade_data["detail"][i]['path'])
		addItem(upgrade_data["detail"][i])
		

func sendInfo(code,detail, number):
	select_index = code
	detail_index = detail
	number_index = number
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = "Mô tả :" + " " +detail +"\n" + "Số lượng :" + " " + number 
	
func addItem(value):
	var item = ListItem.instantiate()
	index += 1
	item.get_node("Code").text = str(value['#'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Detail").text = str(value['detail'])
	item.get_node("Number").text = str(value['number'])
	$Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.add_child(item)

func _on_nut_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	print("add")
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
func reset():
	for i in $Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.get_children():
		remove_child(i)
		i.queue_free()
	index = 0
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/upgrade.json", FileAccess.READ)
	upgrade_data = JSON.parse_string(file2.get_as_text())
	file2.close()	
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.money)
	number_index = str(int(number_index) + 1)
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = "Mô tả : " + str(detail_index) + "\n" + "Số lượng : " + number_index
	for i in upgrade_data["detail"].size() :
		addItem(upgrade_data["detail"][i])

func _on_nut_nang_cap_pressed():
	for i in upgrade_data["detail"].size():
		if upgrade_data["detail"][i]["#"] == int(select_index):
			upgrade_data["detail"][i]["number"] +=1	
	
	var file = FileAccess.open("res://resources/game_data/upgrade.json", FileAccess.WRITE)
	var json_data = JSON.stringify(upgrade_data)
	file.store_string(json_data)
	file.close()
	reset()
