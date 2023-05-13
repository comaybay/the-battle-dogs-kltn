extends Control

const ListCharacter = preload("res://scenes/selectCharacter/box_character.tscn")
var character_data 
var game_data
var team_number = 0
var list_team = [] #danh sách đội hình
var teams # node đội hình
var base_img = load("res://resources/images/base.png")

func _ready():
	game_data = Data.save_data
	var file2 = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	$Khung/PhanDau/TieuDe/Xuong/Label.text = "Xương: "+ str(game_data["bone"])
	# đưa đội hình hiện tại vào teams
	teams = $Khung/PhanGiua/PhanTren/DoiHinh/ScrollContainer/GridContainer.get_children()	
	for i in teams :
		i.get_node("TextureRect").texture = base_img
		i.get_node("ID").text = "-1"
	# Thiết lập nhân vật
	
	for i in character_data.size() :
		for obj in game_data["dogs"]:
			if (str(obj["ID"]) == str(character_data[i]["ID"])):
				
				addItem(character_data[i])
				
		
	loadTeam(Data.save_data['selected_team'])
	

func loadTeam(i) :
	for obj in game_data["teams"][i]["dog_ids"]:
		
		for ob in character_data :
			if (str(obj) == str(ob["ID"]) ):
				var list = $Khung/PhanGiua/PhanDuoi/NhanVat/ScrollContainer/GridContainer.get_children()
				var item = [obj, load(ob["path"]), ob["name_id"]]
				#print(ob["name_id"])
				list[int(item[0])].visible = false
				list_team.push_back(item)
				team_number += 1
	reset()

func reset() :
	for i in range(0,10):
		if i < team_number:
			teams[i].get_node("ID").text = str(list_team[i][0])	
			teams[i].get_node("TextureRect").texture = list_team[i][1]
			teams[i].get_node("Name_id").text = list_team[i][2]
		else :
			teams[i].get_node("TextureRect").texture = base_img
			teams[i].get_node("ID").text = "-1"
			teams[i].get_node("Name_id").text = "ooo"


# thêm vào danh sách nhân vật
func addItem(value):
	var item = ListCharacter.instantiate()
	item.get_node("ID").text = str(value['ID'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Name_id").text = str(value['name_id'])
	$Khung/PhanGiua/PhanDuoi/NhanVat/ScrollContainer/GridContainer.add_child(item)

# thêm vào đội hình
func sendInfo(ID, detail, path, nameID):
	$Khung/PhanGiua/PhanTren/DoiHinh/click.play()
	if (team_number < 10) and (int(ID) >= 0):
		var item = [ID, path, nameID]
		teams[team_number].get_node("TextureRect").texture = path
		teams[team_number].get_node("ID").text = ID
		teams[team_number].get_node("Name_id").text = nameID
		print(nameID)
		list_team.push_back(item)
		
		team_number += 1
	else :
		teams[9].get_node("TextureRect").texture = path
	
# Xóa khỏi đội hình
func deleteInfo(ID, path, index, nameID):
	$Khung/PhanGiua/PhanTren/DoiHinh/click.play()
	if (int(ID) >= 0) :
		var list = $Khung/PhanGiua/PhanDuoi/NhanVat/ScrollContainer/GridContainer.get_children()
		
		list_team.remove_at(int(index)-1)
		team_number -= 1
		list[int(ID)].visible = true
		reset()
	else : 
		print("sai")

func _process(delta):
	pass


func _on_quay_lai_pressed():
	$Khung/PhanGiua/PhanDuoi/TieuDe/Luu.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_luu_pressed():
	#print(list_team)
	$Khung/PhanGiua/PhanDuoi/TieuDe/Luu.play()
	var items = []
	var item_name = []
	#list_team.push_back(item)
	for obj in list_team :
		items.push_back(int(obj[0]))
		item_name.push_back(str(obj[2]))
		
	
	game_data["teams"][Data.save_data['selected_team']]["dog_ids"] = items
	game_data["teams"][Data.save_data['selected_team']]["dog_name_ids"] = item_name
	
	var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
	var json_data = JSON.stringify(game_data)
	file.store_string(json_data)
	file.close()
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

