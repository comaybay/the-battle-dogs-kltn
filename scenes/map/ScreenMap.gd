extends Node2D

@export var level_now = 3

var game_data

func _ready():
	game_data = Data.save_data
	
	var levels := $Node.get_children()
	$Tracker.setup(levels, $MapSprite)
	
	for node in levels:
		var level: Level = node
		if level.battlefield_id == Data.selected_battlefield_id:
			level.grab_focus()
			break

func _draw() -> void:
	var allMap = $Node.get_children()	
	for level in game_data['passed_level']:
		var vitri1 = allMap[level].position + Vector2(20,20)
		var vitri2 = allMap[level+1].position+ Vector2(20,20)
		draw_dashed_line(vitri1,vitri2, Color(1, 1, 1, 1), 4, 10, false)

