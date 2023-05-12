extends Node2D

var game_data
# Called when the node enters the scene tree for the first time.
func _ready():
	game_data = Data.save_data

func _draw() -> void:
	var allMap = self.get_children()	
	for level in game_data['passed_level']:
		var vitri1 = allMap[level].position + Vector2(20,20)
		var vitri2 = allMap[level+1].position+ Vector2(20,20)
		draw_dashed_line(vitri1,vitri2, Color(1, 1, 1, 1), 4, 10, false)
