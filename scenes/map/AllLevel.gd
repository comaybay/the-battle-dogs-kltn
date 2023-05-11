class_name Level extends Button

@export var battlefield_id: String 
var game_data

func _ready():
	var file = FileAccess.open("res://resources/save.json", FileAccess.READ)
	game_data = JSON.parse_string(file.get_as_text())
	file.close()

func _on_level_pressed():
	Data.selected_level = int(text)
	Data.selected_battlefield_id = battlefield_id
	
