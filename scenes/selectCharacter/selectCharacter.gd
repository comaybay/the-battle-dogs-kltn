extends Control

const ListCharacter = preload("res://scenes/selectCharacter/box_character.tscn")
var character_data 
var game_data
var team_number = 0
var list_team = [] #danh sách đội hình
var teams # node đội hình
var base_img = load("res://resources/images/base.png")

func _ready():
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	# đưa đội hình hiện tại vào teams
	teams = $Khung/PhanGiua/PhanTren/DoiHinh/ScrollContainer/GridContainer.get_children()	
	for i in teams :
		i.get_node("TextureRect").texture = base_img
		i.get_node("ID").text = "-1"
	# Thiết lập nhân vật
	for i in character_data["detail"].size() :
		#print(upgrade_data["detail"][i]['path'])
		addItem(character_data["detail"][i])
	

func reset() :
	for i in range(0,10):
		if i < team_number:
			teams[i].get_node("ID").text = list_team[i][0]
			teams[i].get_node("TextureRect").texture = list_team[i][1]
		else :
			teams[i].get_node("TextureRect").texture = base_img
			teams[i].get_node("ID").text = "-1"


# thêm vào danh sách nhân vật
func addItem(value):
	var item = ListCharacter.instantiate()
	item.get_node("ID").text = str(value['ID'])
	item.get_node("TextureRect").texture = load(value['path'])
	$Khung/PhanGiua/PhanDuoi/NhanVat/ScrollContainer/GridContainer.add_child(item)

func sendInfo(ID, detail, path):
	#var textu = load(path)
	if (team_number < 10):
		var item = [ID, path]
		teams[team_number].get_node("TextureRect").texture = path
		teams[team_number].get_node("ID").text = ID
		list_team.push_back(item)
		team_number += 1
	else :
		teams[9].get_node("TextureRect").texture = path
	
func deleteInfo(ID, path, index):
	if ( team_number > 0) :
		var list = $Khung/PhanGiua/PhanDuoi/NhanVat/ScrollContainer/GridContainer.get_children()
		list_team.remove_at(int(index)-1)
		team_number -= 1
		#print(ID)
		list[int(ID)].visible = true
		reset()
	else : 
		print("sai")

func _process(delta):
	pass


func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_luu_pressed():
	print(Data.money)
	#get_tree().change_scene_to_file("res://scenes/map/map.tscn")


