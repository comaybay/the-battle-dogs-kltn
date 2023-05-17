extends Control

const ListItem = preload("res://scenes/Upgrade/box.tscn")

var character_data 
var game_data
var price_index = 0
var ID_index = 0
var detail_index = ""
var level_index = 0
var name_index = ""

func _ready():	
	game_data = Data.save_data
	var file2 = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(game_data["bone"])
	
	for i in character_data :			
		addItem(i)
		

func sendInfo(ID,detail, nameBox, level, price):
	ID_index = ID
	detail_index = detail
	level_index = level
	name_index = nameBox
	price_index = price
	if (int(level) == 0) :
		$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text ="Tên : "+ nameBox + "\n" + "Mô tả : " +detail + "\n" + "Giá xương : " + price
		$Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text = "Mua"
	else :
		$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text ="Tên : "+ nameBox + "\n" + "Mô tả : " +detail  + "\n" + "Giá xương : " + price+"\n" + "Cấp độ : "  + level 
		$Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text = "Nâng cấp"
	
func addItem(value):	
	var item = ListItem.instantiate()
	var bone = 0
	item.get_node("ID").text = str(value['ID'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Detail").text = str(value['detail'])
	item.get_node("Name").text = str(value['name'])
	
	item.get_node("Level").text = "0"
	for obj in game_data["dogs"] :
		if str(value['ID']) == str(obj["ID"]):
			item.get_node("Level").text = str(obj["level"])
			break
	
	# tinh toan so tien dua tren level
	if (item.get_node("Level").text == "0"):
		bone = value["price"]
	else :
		bone = int(value["price"]) * (1+ int(item.get_node("Level").text))
	item.get_node("Price").text = str(bone)
	$Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.add_child(item)

func _on_nut_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	print("add")
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
func reset():
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(game_data["bone"]) # trừ tiền
	for i in $Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.get_children():
		remove_child(i)
		i.queue_free()
	var file1 = FileAccess.open("res://resources/save.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	
	level_index = str(int(level_index) + 1)
	price_index = str(int(price_index)/int(level_index) * (int(level_index) +1))
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = "Tên : "+ name_index + "\n" + "Mô tả : " + str(detail_index) + "\n"+ "Giá xương : " + price_index+"\n" + "Cấp độ : " + level_index
	for i in character_data :			
		addItem(i)

func _on_nut_nang_cap_pressed():
	if (game_data["bone"] < int(price_index)) : # ko đủ tiền
			print("ko đủ tiền")
	else :
		print("Đủ tiền")
		if ($Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text == "Nâng cấp"):
			for obj in game_data["dogs"].size():
				#kiem tra tien 
				if (game_data["bone"] < int(price_index)) : # ko đủ tiền
					print("ko đủ tiền")
					break
				#Nang cap / đủ tiền
				if (str(game_data["dogs"][obj]["ID"]) == str(ID_index)):
					game_data["bone"] -=  int(price_index)
					game_data["dogs"][obj]["level"] += 1				
					
		else : #Mua character
			$Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text = "Nâng cấp"
			var item ={"ID": ID_index,"level": 1}
			game_data["bone"] -=  int(price_index)
			game_data["dogs"].push_back(item)
		var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
		var json_data = JSON.stringify(game_data)
		file.store_string(json_data)
		file.close()
		reset()

