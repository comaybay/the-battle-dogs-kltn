extends Control

const ListCharacter = preload("res://scenes/team_setup/box_character.tscn")

var character_id_to_item: Dictionary
var skill_id_to_item: Dictionary
@onready var character_slots: Array[Node] = %CharacterSlots.get_children()
@onready var skill_slots: Array[Node] = %SkillSlots.get_children()

func _ready():
	AudioPlayer.resume_dogbase_music()
	%TabContainer.set_tab_title(0, tr("@CHARACTERS"))
	%TabContainer.set_tab_title(1, tr("@SKILLS"))
	%TabContainer.tab_changed.connect(_on_tab_container_tab_changed)
	%SaveButton.pressed.connect(_on_save_pressed)
	
	# Thiết lập nhân vật và kỹ năng
	loadCharacterList()
	loadSkillList()
	# đưa đội hình hiện tại vào teams	6
	loadTeam()
	
func _exit_tree() -> void:
	AudioPlayer.pause_dogbase_music()

func loadCharacterList() -> void:
	for data in Data.dogs.values():
		var item := create_item(data['ID'], SelectCharacterBox.Type.CHARACTER)
		%CharacterList.add_child(item)
		character_id_to_item[data['ID']] = item
		item.pressed.connect(_on_add_character_to_slot.bind(item))

func loadSkillList() -> void:
	for data in Data.skills.values():
		var item := create_item(data['ID'], SelectCharacterBox.Type.SKILL)
		%SkillList.add_child(item)
		skill_id_to_item[data['ID']] = item
		item.pressed.connect(_on_add_skill_to_slot.bind(item))
		
func _on_add_character_to_slot(item: SelectCharacterBox):
	for slot in character_slots:
		if slot.get_item_type() == SelectCharacterBox.Type.NONE:
			slot.change_item(item.get_item_id(), SelectCharacterBox.Type.CHARACTER) 
			item.visible = false
			return
			

func _on_add_skill_to_slot(item: SelectCharacterBox):
	for slot in skill_slots:
		if slot.get_item_type() == SelectCharacterBox.Type.NONE:
			slot.change_item(item.get_item_id(), SelectCharacterBox.Type.SKILL) 
			item.visible = false
			return
				
func create_item(item_id: String, type: SelectCharacterBox.Type) -> SelectCharacterBox:
	var item = ListCharacter.instantiate()
	item.setup(item_id, type)
	return item
		
func loadTeam() -> void:
	for i in range(10):
		var slot := character_slots[i] 
		var character_id = Data.selected_team['dog_ids'][i]
		if character_id == null:
			slot.clear()
		else:
			slot.change_item(character_id, SelectCharacterBox.Type.CHARACTER)
			character_id_to_item[character_id].visible = false

		slot.pressed.connect(_on_remove_character_from_slot.bind(slot))
			
	for i in range(3):
		var slot := skill_slots[i] 
		var skill_id = Data.selected_team['skill_ids'][i]
		if skill_id == null:
			slot.clear()
		else:
			slot.change_item(skill_id, SelectCharacterBox.Type.SKILL)
			skill_id_to_item[skill_id].visible = false

		slot.pressed.connect(_on_remove_skill_from_slot.bind(slot))
		
func _on_remove_character_from_slot(slot: SelectCharacterBox):
	if slot.get_item_type() != SelectCharacterBox.Type.NONE:
		character_id_to_item[slot.get_item_id()].visible = true
		slot.clear()
		
func _on_remove_skill_from_slot(slot: SelectCharacterBox):
	if slot.get_item_type() != SelectCharacterBox.Type.NONE:
		skill_id_to_item[slot.get_item_id()].visible = true
		slot.clear()
		
func _on_save_pressed():	
	AudioPlayer.play_button_pressed_audio()
	Data.selected_team['dog_ids'] = character_slots.map(func(item: SelectCharacterBox): return item.get_item_id())
	Data.selected_team['skill_ids'] = skill_slots.map(func(item: SelectCharacterBox): return item.get_item_id())
	
	Data.save()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

func move(a) :
	$Luu.play()
	if (a == 1):				
		$Khung/PhanDuoi/DanhSach/Skill.visible = false
		$Khung/PhanDuoi/DanhSach/NhanVat.visible = true
	else :
		$Khung/PhanDuoi/DanhSach/Skill.visible = true
		$Khung/PhanDuoi/DanhSach/NhanVat.visible = false

func _on_tab_container_tab_changed(tab: int):
	if (tab == 0) :
		move(1)
	else :
		move(0)
