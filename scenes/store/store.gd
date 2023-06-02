extends Control

const ListItem = preload("res://scenes/store/box.tscn")

var store_data 
var game_data
var index = 0 
var select_index = [-1,"","",0,0,0] #ID,name, detail, amount, price, max

# Called when the node enters the scene tree for the first time.
func _ready():
	$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = true
	game_data = Data.save_data
	var file2 = FileAccess.open("res://resources/game_data/store.json", FileAccess.READ)
	store_data = JSON.parse_string(file2.get_as_text())
	file2.close()	
	for i in store_data :
		addItem(i)

func addItem(value):
	var item = ListItem.instantiate()
	item.setup(self)
	index += 1
	item.get_node("ID").text = str(value['ID'])
	item.get_node("Name").text = str(value['name'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Detail").text = str(value['detail'])
	item.get_node("Max").text = str(value['max'])
	item.get_node("Price").text = str(value['price'])
	
	item.get_node("Amount").text = "0"
	for obj in game_data["items"]:
		if str(value['ID']) == str(obj["ID"]):
			item.get_node("Amount").text = str(obj["amount"])
			break
	$PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.add_child(item)


func sendInfo(ID,nameBox, detail, amount, price, max):
	$PhanGiua/PhanTren/Items/click.play()	
	select_index[0] = ID
	select_index[1] = nameBox
	select_index[2] = detail
	select_index[3] = amount
	select_index[4] = price
	select_index[5] = max
	$PhanGiua/MarginContainer/PhanDuoi/ThongTin/Label_Item.text = "Tên : "+ nameBox+"\n" + "Mô tả : " +detail +"\n" + "Giá tiền : " + price + "\n"+ "Số lượng : " + str(amount) + "\n"+ "Số lượng tối đa : " + max  
	if (Data.bone >= int(price)) :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = false
	else :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	for i in $PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.get_children():
		remove_child(i)
		i.queue_free()
	index = 0
	var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
	var json_data = JSON.stringify(game_data)
	file.store_string(json_data)
	file.close()
	Data.save()
	if (Data.bone >= int(select_index[4])) :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = false
	else :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = true
	game_data = Data.save_data
	
	select_index[3] = int(select_index[3]) + 1
	#ID,name, detail, amount, price, max
	$PhanGiua/MarginContainer/PhanDuoi/ThongTin/Label_Item.text = "Tên : "+ str(select_index[1])+"\n" + "Mô tả : "+ str(select_index[2]) +"\n" + "Giá tiền : " + str(select_index[4]) +"\n" +"Số lượng : " + str(select_index[3]) + "\n"+ "Số lượng tối đa : " + str(select_index[5])
	for i in store_data :
		addItem(i)

func _on_quay_lai_pressed():
	$NhanNut.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_nut_mua_pressed():
	$NhanNut.play()
	if int(select_index[0]) == -1  :
		print("Chưa chọn vật phẩm")
	elif int(Data.bone ) < int(select_index[4]) :
		print("Ko đủ tiền")
		
	else : # đủ tiền
		print("Đủ tiền")
		if (int(select_index[3]) < int(select_index[5])) : # Thiếu số lượng
			print("Thiếu số lượng / có thể mua")
			Data.bone -= int(select_index[4])
			game_data["bone"] = Data.bone 			
			print("price : "+ select_index[4])
			for i in game_data["items"].size():
				if int(game_data["items"][i]["ID"]) == int(select_index[0]):
					#print(game_data["items"][i]["ID"])
					game_data["items"][i]["amount"] +=1	
					reset()
