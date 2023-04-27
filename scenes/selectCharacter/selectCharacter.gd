extends Control

const ListItem = preload("res://scenes/selectCharacter/box_character.tscn")
var store_data 
var game_data
var index = 0 

func _ready():
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/store.json", FileAccess.READ)
	store_data = JSON.parse_string(file2.get_as_text())
	file2.close()	
	
	for i in store_data["detail"].size() :
		#print(upgrade_data["detail"][i]['path'])
		addItem(store_data["detail"][i])
		

func addItem(value):	
	var item = ListItem.instantiate()
	index += 1
	item.get_node("Number").text = str(value['name'])
	item.get_node("TextureRect").texture = load(value['path'])
	$Khung/PhanGiua/PhanDuoi/NhanVat/ScrollContainer/GridContainer.add_child(item)
	#get_tree().call_group("items", "update_items", [])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_luu_pressed():
	print(Data.money)
	#get_tree().change_scene_to_file("res://scenes/map/map.tscn")
