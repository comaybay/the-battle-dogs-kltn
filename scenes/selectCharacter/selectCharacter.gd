extends Control

const ListCharacter = preload("res://scenes/selectCharacter/box_character.tscn")
var character_data 
var game_data
var team_number = 0
var teams
var base_img = load("res://resources/images/planet9_Wallpaper_5000x2813.jpg")

func _ready():
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	teams = $Khung/PhanGiua/PhanTren/DoiHinh/ScrollContainer/GridContainer.get_children()
	for i in character_data["detail"].size() :
		#print(upgrade_data["detail"][i]['path'])
		addItem(character_data["detail"][i])
	

func addItem(value):
	var item = ListCharacter.instantiate()
	item.get_node("ID").text = str(value['ID'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Detail").text = str(value['detail'])
	$Khung/PhanGiua/PhanDuoi/NhanVat/ScrollContainer/GridContainer.add_child(item)

func sendInfo(ID, detail, path):
	print(path)
	#var textu = load(path)
	if (team_number < 2):
		teams[team_number].get_node("TextureRect").texture = path
		team_number += 1
	else :
		teams[1].get_node("TextureRect").texture = path
	
func _process(delta):
	pass


func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_luu_pressed():
	print(Data.money)
	#get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_box_pressed(bt):
	print(1)
	
	#team_number -= 1
	
