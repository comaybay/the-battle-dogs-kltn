extends Button

var game_data

func _ready():
	var file = FileAccess.open("res://resources/game_data/data.json", FileAccess.READ)
	game_data = JSON.parse_string(file.get_as_text())
	file.close()

func _on_level_pressed():
	#Luu du lieu
	#game_data['level_select'] = text 
	#var file = FileAccess.open("res://resources/game_data/data.json", FileAccess.WRITE)
	#var json_data = JSON.stringify(game_data)
	#file.store_string(json_data)
	#file.close()	
	Data.level_select = text
	
