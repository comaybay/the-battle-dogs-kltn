extends Control

const ListItem = preload("res://scenes/Upgrade/item_box.tscn")

var character_data 
var skill_data 
var selected_item: ItemBox

var dog_boxes: Array[ItemBox]
var skill_boxes: Array[ItemBox]

func _ready():
	%NutNangCap.disabled = true
	%TabContainer.set_tab_title(0, "Nhân vật")
	%TabContainer.set_tab_title(1, "Kỹ năng")
	add_items()
	selected_item = dog_boxes[0]
	
	# show first item
	update_ui(selected_item)
		
func add_items():
	for dog in Data.dog_info.values():			
		addItemDog(dog)
		
	for skill in Data.skill_info.values():			
		addItemSkill(skill)

func sendInfo(item: ItemBox):
	$click.play()
	update_ui(item)

func update_ui(item: ItemBox):
	selected_item.set_selected(false)
	selected_item = item
	selected_item.set_selected(true)
	
	var data = item.get_item_data()
	%ItemName.text = data["name"] 
	%ItemDescription.text = data['detail']
	%NutNangCap.text = "Nâng cấp" if selected_item.get_level() > 0 else "Mua" 
	%NutNangCap.disabled = selected_item.get_price() > Data.bone
	
func addItemDog(value: Dictionary) -> void:
	var item = ListItem.instantiate()
	var bone = 0
	item.setup(value, "character", self)
	%NhanVat/MarginContainer/GridContainer.add_child(item)
	dog_boxes.append(item)

func addItemSkill(skill: Dictionary) -> void:
	var item = ListItem.instantiate()
	var bone = 0
	item.setup(skill, "skill", self)
	%Skill/MarginContainer/GridContainer.add_child(item)
	skill_boxes.append(item)

func _on_nut_quay_lai_pressed():
	AudioPlayer.play_button_pressed_audio()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_box_pressed(button):
	$PhanGiua/PhanDuoi/ThongTin/Label_Item.text = button.text
	
func reset():
	selected_item.update_labels()
	%NutNangCap.disabled = selected_item.get_price() > Data.bone
	%NutNangCap.text = "Nâng cấp"

func _on_nut_nang_cap_pressed():
	AudioPlayer.play_button_pressed_audio()
	Data.bone -= selected_item.get_price()
	
	if selected_item.get_level() > 0:
		if selected_item.get_item_type() == "skill":
			Data.skills[selected_item.get_item_id()]['level'] += 1
		else :
			Data.dogs[selected_item.get_item_id()]['level'] += 1
	else : 
		var item = {"ID": selected_item.get_item_id(), "level": 1}
		if selected_item.get_item_type() == "skill":
			Data.save_data["skills"].append(item)
		else :
			Data.save_data["dogs"].append(item)
			
	Data.save()
	reset()
	
