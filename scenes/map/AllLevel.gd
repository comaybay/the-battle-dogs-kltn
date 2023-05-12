class_name Level extends Button

@export var battlefield_id: String 
var game_data

func _ready():
	game_data = Data.save_data

func _on_level_pressed():
	Data.selected_level = int(text)
	Data.selected_battlefield_id = battlefield_id


