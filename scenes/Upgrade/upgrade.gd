extends Control

const ListItem = preload("res://scenes/Upgrade/item_box.tscn")

var character_data 
var skill_data 
var selected_item: ItemUpgradeBox
var last_selected_item_character: ItemUpgradeBox
var last_selected_item_skill: ItemUpgradeBox
var last_selected_item_passive: ItemUpgradeBox

var dog_boxes: Array[ItemUpgradeBox]
var skill_boxes: Array[ItemUpgradeBox]
var passive_boxes: Array[ItemUpgradeBox]

func _ready():
	%NutNangCap.disabled = true
	%TabContainer.set_tab_title(0, "Nhân vật")
	%TabContainer.set_tab_title(1, "Kỹ năng")
	%TabContainer.set_tab_title(2, "Nội tại")
	%TabContainer.tab_changed.connect(func(tab: int):
		var options = [last_selected_item_character, last_selected_item_skill, last_selected_item_passive]
		update_ui(options[tab]) 
	)
		
	add_items()
	selected_item = dog_boxes[0]
	last_selected_item_character = dog_boxes[0]
	last_selected_item_skill = skill_boxes[0]
	last_selected_item_passive = passive_boxes[0]
	
	# show first item
	update_ui(selected_item)
		
func add_items():
	var type := ItemUpgradeBox.Type
	
	for data in Data.dog_info.values():			
		var dog_item_box := createItemBox(type.CHARACTER, data, %NhanVat/MarginContainer/GridContainer)
		dog_boxes.append(dog_item_box)
		
	for data in Data.skill_info.values():			
		var skill_item_box := createItemBox(type.SKILL, data, %Skill/MarginContainer/GridContainer)
		skill_boxes.append(skill_item_box)

	for data in Data.passive_info.values():			
		var passive_item_box := createItemBox(type.PASSIVE, data, %Passives/MarginContainer/GridContainer)
		passive_boxes.append(passive_item_box)

func sendInfo(item: ItemUpgradeBox):
	$click.play()
	update_ui(item)

func update_ui(item: ItemUpgradeBox):
	selected_item.set_selected(false)
	selected_item = item
	selected_item.set_selected(true)
	
	var type := item.get_item_type() 
	if type == ItemUpgradeBox.Type.SKILL:
		last_selected_item_skill = selected_item
	elif type == ItemUpgradeBox.Type.CHARACTER:
		last_selected_item_character = selected_item
	else:
		last_selected_item_passive = selected_item
	
	var data = item.get_item_data()
	%ItemName.text = data["name"] 
	%ItemDescription.text = data['description']
	%NutNangCap.text = "Nâng cấp" if selected_item.get_level() > 0 else "Mở khóa" 
	%NutNangCap.disabled = selected_item.get_price() > Data.bone
	
func createItemBox(type: ItemUpgradeBox.Type, data: Dictionary, container: GridContainer) -> ItemUpgradeBox:
	var item = ListItem.instantiate()
	item.setup(type, data, self)
	container.add_child(item)
	return item

func _on_nut_quay_lai_pressed():
	AudioPlayer.play_button_pressed_audio()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	$PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
func reupdate_current_ui():
	selected_item.update_labels()
	%NutNangCap.disabled = selected_item.get_price() > Data.bone
	%NutNangCap.text = "Nâng cấp"

func _on_nut_nang_cap_pressed():
	AudioPlayer.play_button_pressed_audio()
	Data.bone -= selected_item.get_price()
	
	var type := selected_item.get_item_type() 
	var item_id := selected_item.get_item_id()
	
	if selected_item.get_level() > 0:
		if type == ItemUpgradeBox.Type.SKILL:
			Data.skills[item_id]['level'] += 1
		elif type == ItemUpgradeBox.Type.CHARACTER:
			Data.dogs[item_id]['level'] += 1
		else:
			Data.passives[item_id]['level'] += 1
	
	else: 
		var item = {"ID": item_id, "level": 1}
		if  type == ItemUpgradeBox.Type.SKILL:
			Data.save_data["skills"].append(item)
		elif type == ItemUpgradeBox.Type.CHARACTER:
			Data.save_data["dogs"].append(item)
		else:
			Data.save_data["passives"].append(item)
	
	Data.save()
	reupdate_current_ui()
