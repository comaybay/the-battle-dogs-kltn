extends Button


func _ready():
	pass

func _on_level_pressed() -> void:
	Data.level_pass = text
	print(Data.level_pass)
