extends Control

const ListItem = preload("res://scenes/Upgrade/item_box.tscn")

var character_data 
var skill_data 
var game_data
var price_index = 0
var ID_index = 0
var detail_index = ""
var level_index = 0
var name_index = ""
var character_or_skill := true
var selected_item: Node

func _ready():	
	game_data = Data.save_data
	add_items()
		
func add_items():
	for dog in Data.dog_info.values():			
		addItemDog(dog)
		
	for skill in Data.skill_info.values():			
		addItemSkill(skill)

func sendInfo(item: Node, data: Dictionary):
	$click.play()
	selected_item = item
	ID_index = data['ID']
	detail_index = data['detail']
	
	if character_or_skill and Data.dogs.has(ID_index):
		level_index = Data.dogs[ID_index]['level']
	elif !character_or_skill and Data.skills.has(ID_index):
		level_index = Data.skills[ID_index]['level']
	else:
		level_index = 0	
	
	name_index = data["name"]
	price_index = int(data['price'])
	if (level_index == 0) :
		%ItemLabel.text ="Tên : "+ name_index + "\n" + "Mô tả : " + detail_index + "\n" + "Giá xương : " + str(price_index * pow(2,level_index))
		%NutNangCap.text = "Mua"
	else :
		%ItemLabel.text = "Tên : "+ name_index + "\n" + "Mô tả : " + detail_index  + "\n" + "Giá xương : " + str(price_index * pow(2,level_index)) + "\n" + "Cấp độ : "  + str(level_index) 
		%NutNangCap.text = "Nâng cấp"
		
	%NutNangCap.disabled = price_index * pow(2,level_index) > Data.bone
	
func addItemDog(value: Dictionary) -> void:
	var item = ListItem.instantiate()
	var bone = 0
	item.setup(value, self)
	
	for obj in Data.save_data["dogs"] :
		if str(value['ID']) == str(obj["ID"]):
			item.get_node("Level").text = str(obj["level"])
			break
			# tinh toan so tien dua tren level
		bone =int(value["price"]) * pow(2,int(item.get_node("Level").text)) 
		item.get_node("Price").text = str(value["price"])
	%NhanVat/GridContainer.add_child(item)

func addItemSkill(skill: Dictionary) -> void:
	var item = ListItem.instantiate()
	var bone = 0
	item.setup(skill, self)

	for obj in Data.save_data["skills"] :
		if str(skill['ID']) == str(obj["ID"]):
			item.get_node("Level").text = str(obj["level"])
			break
			# tinh toan so tien dua tren level
		bone = int(skill["price"]) * pow(2,int(item.get_node("Level").text)) 
		item.get_node("Price").text = str(skill["price"])
	%Skill/GridContainer.add_child(item)

func _on_nut_quay_lai_pressed():
	$button.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	print("add")
	$PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
func reset():
	level_index = int(level_index) + 1
	var gia = str(int(price_index) * pow(2,int(level_index) ))
	$PhanGiua/PhanDuoi/ThongTin/ItemLabel.text = "Tên : "+ name_index + "\n" + "Mô tả : " + str(detail_index) + "\n"+ "Giá xương : " + gia+"\n" + "Cấp độ : " + str(level_index)
	%NutNangCap.disabled = price_index * pow(2,level_index) > Data.bone

func _on_nut_nang_cap_pressed():
	AudioPlayer.play_button_pressed_audio()
	var gia = str(int(price_index) * pow(2,int(level_index) ))
	#kiem tra tien 
	if (game_data["bone"] < int(gia)) : # ko đủ tiền
			print("ko đủ tiền:")
	else :
		# Đủ tiền
		if ($PhanGiua/PhanDuoi/TieuDe/NutNangCap.text == "Nâng cấp"):
			if (character_or_skill == true):
				for obj in game_data["dogs"].size():#Nang cap / đủ tiền
					if (str(game_data["dogs"][obj]["ID"]) == str(ID_index)):
						Data.bone -=  int(gia)
						game_data["dogs"][obj]["level"] += 1
						break
			else :
				for obj in game_data["skills"].size():#Nang cap / đủ tiền
					if (str(game_data["skills"][obj]["ID"]) == str(ID_index)):
						Data.bone -=  int(gia)
						game_data["skills"][obj]["level"] += 1
						break
		else : #Mua character
			$PhanGiua/PhanDuoi/TieuDe/NutNangCap.text = "Nâng cấp"
			var item ={"ID": ID_index,"level": 1}
			if (character_or_skill == true):
				Data.bone -=  int(gia)
				game_data["dogs"].push_back(item)
			else :
				Data.bone -=  int(gia)
				game_data["skills"].push_back(item)
		Data.save()
		reset()
	

func _on_tab_container_tab_changed(tab: int) -> void:
	character_or_skill = true if tab == 0 else false
