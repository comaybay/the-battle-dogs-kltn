extends Control

const ListItem = preload("res://scenes/Upgrade/box.tscn")

var character_data 
var skill_data 
var game_data
var price_index = 0
var ID_index = 0
var detail_index = ""
var level_index = 0
var name_index = ""
var character_or_skill := true
func _ready():	
	game_data = Data.save_data
	var file2 = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	file2 = FileAccess.open("res://resources/game_data/skill.json", FileAccess.READ)
	skill_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.bone)
	
	for i in character_data :			
		addItem(i, 0)
	for i in skill_data :			
		addItem(i, 1)

func sendInfo(ID,detail, nameBox, level, price):
	$click.play()
	ID_index = ID
	detail_index = detail
	level_index = level
	name_index = nameBox
	var gia = str(int(price) * pow(2,int(level) ))
	price_index = price
	if (int(level) == 0) :
		$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text ="Tên : "+ nameBox + "\n" + "Mô tả : " +detail + "\n" + "Giá xương : " + gia
		$Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text = "Mua"
	else :
		$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text ="Tên : "+ nameBox + "\n" + "Mô tả : " +detail  + "\n" + "Giá xương : " + gia+"\n" + "Cấp độ : "  + level 
		$Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text = "Nâng cấp"
	
func addItem(value,type):
	var item = ListItem.instantiate()
	var bone = 0
	item.get_node("ID").text = str(value['ID'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Detail").text = str(value['detail'])
	item.get_node("Name").text = str(value['name'])
	
	item.get_node("Level").text = "0"

	if (type == 0):
		for obj in game_data["dogs"] :
			if str(value['ID']) == str(obj["ID"]):
				item.get_node("Level").text = str(obj["level"])
				break
				# tinh toan so tien dua tren level
		bone =int(value["price"]) * pow(2,int(item.get_node("Level").text)) 
		item.get_node("Price").text = str(value["price"])
		$Khung/PhanGiua/PhanTren/Items/NhanVat/GridContainer.add_child(item)
	else : 
		for obj in game_data["skills"] :
			if str(value['ID']) == str(obj["ID"]):
				item.get_node("Level").text = str(obj["level"])
				break
				# tinh toan so tien dua tren level
		bone =int(value["price"]) * pow(2,int(item.get_node("Level").text)) 
		item.get_node("Price").text = str(value["price"])
		$Khung/PhanGiua/PhanTren/Items/Skill/GridContainer.add_child(item)

func _on_nut_quay_lai_pressed():
	$button.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	print("add")
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
func reset():
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(game_data["bone"]) # trừ tiền
	for i in $Khung/PhanGiua/PhanTren/Items/NhanVat/GridContainer.get_children():
		remove_child(i)
		i.queue_free()
	for i in $Khung/PhanGiua/PhanTren/Items/Skill/GridContainer.get_children():
		remove_child(i)
		i.queue_free()
	var file = FileAccess.open("res://resources/save.json", FileAccess.READ)
	game_data = JSON.parse_string(file.get_as_text())
	file.close()
	file = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file.get_as_text())
	file.close()
	file = FileAccess.open("res://resources/game_data/skill.json", FileAccess.READ)
	skill_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	level_index = str(int(level_index) + 1)
	var gia = str(int(price_index) * pow(2,int(level_index) ))
	
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = "Tên : "+ name_index + "\n" + "Mô tả : " + str(detail_index) + "\n"+ "Giá xương : " + gia+"\n" + "Cấp độ : " + level_index
	for i in character_data :
		addItem(i,0)
	for i in skill_data :
		addItem(i,1)

func _on_nut_nang_cap_pressed():
	$button.play()
	var gia = str(int(price_index) * pow(2,int(level_index) ))
	#kiem tra tien 
	if (game_data["bone"] < int(gia)) : # ko đủ tiền
			print("ko đủ tiền:")
	else :
		# Đủ tiền
		if ($Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text == "Nâng cấp"):
			if (character_or_skill == true):
				for obj in game_data["dogs"].size():#Nang cap / đủ tiền
					if (str(game_data["dogs"][obj]["ID"]) == str(ID_index)):
						game_data["bone"] -=  int(gia)
						game_data["dogs"][obj]["level"] += 1				
			else :
				for obj in game_data["skills"].size():#Nang cap / đủ tiền
					if (str(game_data["skills"][obj]["ID"]) == str(ID_index)):
						game_data["bone"] -=  int(gia)
						game_data["skills"][obj]["level"] += 1		
		else : #Mua character
			$Khung/PhanGiua/PhanDuoi/TieuDe/NutNangCap.text = "Nâng cấp"
			var item ={"ID": ID_index,"level": 1}
			if (character_or_skill == true):
				game_data["bone"] -=  int(gia)
				game_data["dogs"].push_back(item)
			else :
				game_data["bone"] -=  int(gia)
				game_data["skills"].push_back(item)
		var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
		var json_data = JSON.stringify(game_data)
		file.store_string(json_data)
		file.close()
		reset()


func move(set) :
	$button.play()
	var character_row = $Khung/PhanGiua/PhanTren/Items/NhanVat
	var skill_row = $Khung/PhanGiua/PhanTren/Items/Skill
	var tween = create_tween()
	tween.set_parallel(false).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	if (set == 1):
		skill_row.scale = Vector2(1,0)
		skill_row.visible = true
		tween.tween_property(character_row, "scale", Vector2(1,0), 0.5)
		tween.tween_property(skill_row, "scale", Vector2(1,1), 0.5) 
		await get_tree().create_timer(1).timeout
		character_row.visible = false
		character_row.scale = Vector2(1,1)
	else:
		character_row.scale = Vector2(1,0)
		character_row.visible = true
		tween.tween_property(skill_row, "scale", Vector2(1,0), 0.5)
		tween.tween_property(character_row, "scale", Vector2(1,1), 0.5) 
		await get_tree().create_timer(1).timeout
		skill_row.visible = false
		skill_row.scale = Vector2(1,1)

func _on_skill_pressed():
	if ( $Khung/PhanGiua/PhanTren/Items/Skill.visible == false):
		character_or_skill = false
		move(1)
func _on_doi_hinh_pressed():
	if ($Khung/PhanGiua/PhanTren/Items/NhanVat.visible == false):
		character_or_skill = true
		move(0)
