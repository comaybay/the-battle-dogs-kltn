extends Control

const ListItem = preload("res://scenes/store/box.tscn")

var store_data 
var selected_item: ItemStoreBox
var item_boxes: Array[ItemStoreBox]

func _ready():
	for item in Data.store_info.values() :
		addItem(item)
	selected_item = item_boxes[0]

func addItem(value: Dictionary) -> void:
	var item = ListItem.instantiate()
	item.setup(value, self)
	$PhanGiua/PhanTren/Items/ScrollContainer/GridContainer.add_child(item)
	item_boxes.append(item)

func sendInfo(item: Node, data: Dictionary):
	$PhanGiua/PhanTren/Items/click.play()
	selected_item.set_selected(false)
	selected_item = item
	selected_item.set_selected(true)
	$PhanGiua/MarginContainer/PhanDuoi/ThongTin/Label_Item.text =  "Tên: " + data["name"] +"\n" + "Số lượng tối đa: "+ str(data["max"]) + "\n" +  data['description'] 
	if (selected_item.get_price() < Data.bone) and (selected_item.get_amount() < data["max"]) :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = false 
	else :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	selected_item.update_labels()
	if (selected_item.get_price() < Data.bone) and (selected_item.get_amount() <selected_item.get_max()) :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = false 
	else :
		$PhanGiua/MarginContainer/PhanDuoi/TieuDe2/NutMua.disabled = true


func _on_quay_lai_pressed():
	$NhanNut.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_nut_mua_pressed():
	AudioPlayer.play_button_pressed_audio()
	Data.bone -= selected_item.get_price()
	
	if selected_item.get_amount() > 0:
		Data.store[selected_item.get_item_id()]['amount'] += 1
	else : 
		var item = {"ID": selected_item.get_item_id(), "amount": 1}
		Data.save_data["items"].append(item)
		
	Data.save()
	reset()
