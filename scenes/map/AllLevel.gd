extends Button

var all_level = 6
var level_pass = 3 
var level_select
func _ready():
	pass

func _on_level_pressed() -> void:	
	print(text)
	level_pass = text
