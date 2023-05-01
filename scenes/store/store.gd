extends Control

const ListItem = preload("res://scenes/store/box.tscn")

var store_data 
var game_data
var index = 0 
var select_index = 0
var detail_index = ""
var number_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/store.json", FileAccess.READ)
	store_data = JSON.parse_string(file2.get_as_text())
	file2.close()	
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.money)
	#var group = $Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.get_children()
	for i in store_data["detail"].size() :
		addItem(store_data["detail"][i])


func sendInfo(code,detail, number):
	select_index = code
	detail_index = detail
	number_index = number
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = "Mô tả : " +detail +"\n" + "Số lượng : " + number 
	

func addItem(value):
	var item = ListItem.instantiate()
	index += 1
	item.get_node("Code").text = str(value['#'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Detail").text = str(value['detail'])
	item.get_node("Number").text = str(value['number'])
	$Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.add_child(item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	for i in $Khung/PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.get_children():
		remove_child(i)
		i.queue_free()
	index = 0
	var file1 = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file1.get_as_text())
	file1.close()
	var file2 = FileAccess.open("res://resources/game_data/store.json", FileAccess.READ)
	store_data = JSON.parse_string(file2.get_as_text())
	file2.close()	
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.money)
	number_index = str(int(number_index) + 1)
	$Khung/PhanGiua/PhanDuoi/ThongTin/Label_Item.text = "Mô tả : " + str(detail_index) + "\n" + "Số lượng : " + number_index
	for i in store_data["detail"].size() :
		addItem(store_data["detail"][i])

func _on_mua_pressed():
	for i in store_data["detail"].size():
		if store_data["detail"][i]["#"] == int(select_index):
			store_data["detail"][i]["number"] +=1	
	
	var file = FileAccess.open("res://resources/game_data/store.json", FileAccess.WRITE)
	var json_data = JSON.stringify(store_data)
	file.store_string(json_data)
	file.close()
	reset()


func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_nut_quay_lai_pressed():
	pass # Replace with function body.
