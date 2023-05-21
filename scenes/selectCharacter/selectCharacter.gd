extends Control

const ListCharacter = preload("res://scenes/selectCharacter/box_character.tscn")
var character_data 
var skill_data 
var game_data

var list_team = [] #danh sách đội hình
var list_skill = [] #danh sách kỹ năng
var teams # node đội hình đã chọn
var skill_teams # node kỹ năng đã chọn
var base_img = load("res://resources/images/base.png")

func _ready():
	game_data = Data.save_data
	var file2 = FileAccess.open("res://resources/game_data/character.json", FileAccess.READ)
	character_data = JSON.parse_string(file2.get_as_text())
	file2.close()
	
	var file3 = FileAccess.open("res://resources/game_data/skill.json", FileAccess.READ)
	skill_data = JSON.parse_string(file3.get_as_text())
	file2.close()
	
	$Khung/PhanDau/TieuDe/Xuong/Label.text = "Xương: "+ str( Data.bone)
	# làm trống đội hình và kỹ năng
	teams = $Khung/PhanGiua/PhanTren/DoiHinh/DoiHinh/GridContainer.get_children()	
	skill_teams = $Khung/PhanGiua/PhanTren/DoiHinh/Skill/GridContainer.get_children()
	for i in teams :
		i.get_node("TextureRect").texture = base_img
		i.get_node("ID").text = "-1"
	for i in skill_teams :
		i.get_node("TextureRect").texture = base_img
		i.get_node("ID").text = "-1"
	
	# Thiết lập nhân vật và kỹ năng
	loadCharacter()
	loadSkill()
	# đưa đội hình hiện tại vào teams	
	loadTeam(Data.save_data['selected_team'])
	

func loadCharacter() :
	for i in character_data.size() :
		for obj in game_data["dogs"]:
			if (str(obj["ID"]) == str(character_data[i]["ID"])):
				addItem(character_data[i],0)
				

func loadSkill() :
	for i in skill_data.size() :
		for obj in game_data["skills"]:
			if (str(obj["ID"]) == str(skill_data[i]["ID"])):
				addItem(skill_data[i],1)

func addItem(value,type):
	var item = ListCharacter.instantiate()
	item.get_node("ID").text = str(value['ID'])
	item.get_node("TextureRect").texture = load(value['path'])
	item.get_node("Type").text = str(type)
	if (type == 0) :
		$Khung/PhanGiua/PhanDuoi/DanhSach/NhanVat/GridContainer.add_child(item)
	else :
		$Khung/PhanGiua/PhanDuoi/DanhSach/Skill/GridContainer.add_child(item)
	
func loadTeam(i) :
	for obj in game_data["teams"][i]["dog_ids"]:
		for ob in character_data :
			if (str(obj) == str(ob["ID"])) and (obj != null):
				var list = $Khung/PhanGiua/PhanDuoi/DanhSach/NhanVat/GridContainer.get_children()
				var item = [ob["ID"], load(ob["path"])]
				for it in list.size() :
					if (list[it].get_node("ID").text == ob["ID"] ):
						list[it].visible = false
						break
				list_team.push_back(item)
				
	resetTeam()
	for obj in game_data["teams"][i]["skill_ids"]:
		for ob in skill_data :
			if (str(obj) == str(ob["ID"])) and (obj != null):
				var listSK = $Khung/PhanGiua/PhanDuoi/DanhSach/Skill/GridContainer.get_children()
				var item = [ob["ID"], load(ob["path"])]
				for it in listSK.size() :
					if (listSK[it].get_node("ID").text == ob["ID"] ):
						listSK[it].visible = false
						break
				list_skill.push_back(item)
				
	resetSkill()

# thêm vào đội hình
func sendInfo(ID, path,type):
	$Khung/PhanGiua/PhanTren/DoiHinh/click.play()
	var item = [ID, path]
	print("item:" + str(item))
	if (int(type) == 0 ) :
		if (list_team.size() < 10) :		
			teams[list_team.size()].get_node("TextureRect").texture = path
			teams[list_team.size()].get_node("ID").text = ID	
			list_team.push_back(item)
		elif (list_team.size() == 10) : 
			deleteInfo(teams[9].get_node("ID").text,teams[9].get_node("TextureRect").texture,9)
			teams[9].get_node("TextureRect").texture = path
			teams[9].get_node("ID").text = ID
			list_team.push_back(item)
			
	if (int(type) == 1 ) : #OK
		if (list_skill.size() <= 2) :
			skill_teams[list_skill.size()].get_node("TextureRect").texture = path
			skill_teams[list_skill.size()].get_node("ID").text = ID
			list_skill.push_back(item)
			
		elif (list_skill.size() == 3) :
			deleteSkillInfo(skill_teams[2].get_node("ID").text, skill_teams[2].get_node("TextureRect").texture, 2)
			skill_teams[2].get_node("TextureRect").texture = path
			skill_teams[2].get_node("ID").text = ID			
			list_skill.push_back(item)


# Xóa khỏi đội hình
func deleteSkillInfo(ID, path, index):
	$Khung/PhanGiua/PhanTren/DoiHinh/click.play()
	if (str(ID) != "-1") :
		var list = $Khung/PhanGiua/PhanDuoi/DanhSach/Skill/GridContainer.get_children()
		list_skill.remove_at(int(index))
		for i in list :
				if (i.get_node("ID").text == ID ):
					i.visible = true
					break
		
		resetSkill()
	else : 
		print("sai")

func deleteInfo(ID, path, index):
	$Khung/PhanGiua/PhanTren/DoiHinh/click.play()
	if (str(ID) != "-1") :
		var list = $Khung/PhanGiua/PhanDuoi/DanhSach/NhanVat/GridContainer.get_children()		
		list_team.remove_at(int(index))
		for it in list :
				if (it.get_node("ID").text == ID ):
					it.visible = true					
					break
		#list[int(ID)].visible = true
		resetTeam()
	else : 
		print("sai")


func resetTeam() :
	for i in range(0,10):
		if i < list_team.size():
			teams[i].get_node("ID").text = str(list_team[i][0])	
			teams[i].get_node("TextureRect").texture = list_team[i][1]
		else :
			teams[i].get_node("TextureRect").texture = base_img
			teams[i].get_node("ID").text = "-1"

func resetSkill() :	
	for i in range(0,3):		
		if i < (list_skill.size()):
			skill_teams[i].get_node("ID").text = str(list_skill[i][0])
			skill_teams[i].get_node("TextureRect").texture = list_skill[i][1]
		else :
			skill_teams[i].get_node("TextureRect").texture = base_img
			skill_teams[i].get_node("ID").text = "-1"
			

func _on_quay_lai_pressed():
	$Khung/PhanGiua/PhanDuoi/TieuDe/Luu.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_luu_pressed():	
	
	var items = []
	for obj in list_team :
		items.push_back(str(obj[0]))
	
	for obj in (10- list_team.size()) :
		items.push_back(null)
	game_data["teams"][Data.save_data['selected_team']]["dog_ids"] = items
	
	var skill_items = []
	for obj in list_skill :
		skill_items.push_back(str(obj[0]))
		
	for obj in (3- list_team.size()) :
		skill_items.push_back(null)
	game_data["teams"][Data.save_data['selected_team']]["skill_ids"] = skill_items
	
	var file = FileAccess.open("res://resources/save.json", FileAccess.WRITE)
	var json_data = JSON.stringify(game_data)
	file.store_string(json_data)
	file.close()
	Data.save_data = game_data
	
	
	$Khung/PhanGiua/PhanDuoi/TieuDe/Luu.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")


func _on_ky_nang_pressed():
	$Khung/PhanGiua/PhanDuoi/TieuDe/Luu.play()
	if ( $Khung/PhanGiua/PhanTren/DoiHinh/Skill.visible == false):	
		$Khung/PhanGiua/PhanDuoi/DanhSach/Skill.visible = true
		$Khung/PhanGiua/PhanDuoi/DanhSach/NhanVat.visible = false
		move(0)
	

func move(set) :
	var character_row = $Khung/PhanGiua/PhanTren/DoiHinh/DoiHinh/GridContainer
	var skill_row = $Khung/PhanGiua/PhanTren/DoiHinh/Skill
	if (set == 0):
		skill_row.visible = true
		var tween = create_tween()
		tween.set_parallel(true).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(character_row, "position", skill_row.position, 0.2)
		tween.tween_property(skill_row, "position", character_row.position, 0.2)
		character_row.visible = false
		tween.finished.connect(func(): false)
	else :
		character_row.visible = true
		var tween = create_tween()
		tween.set_parallel(true).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(skill_row, "position",  character_row.position, 0.2)
		tween.tween_property(character_row, "position", skill_row.position, 0.2)
		skill_row.visible = false
		tween.finished.connect(func(): false)
		

func _on_doi_hinh_pressed():
	$Khung/PhanGiua/PhanDuoi/TieuDe/Luu.play()
	if ($Khung/PhanGiua/PhanTren/DoiHinh/DoiHinh/GridContainer.visible == false):
		$Khung/PhanGiua/PhanDuoi/DanhSach/Skill.visible = false
		$Khung/PhanGiua/PhanDuoi/DanhSach/NhanVat.visible = true
		move(1)
	


