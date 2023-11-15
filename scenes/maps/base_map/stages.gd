extends Node2D

@onready var levels = get_children()	

func _draw() -> void:
	print( Data.passed_level)
	for level in Data.passed_level:
		var vitri1 = levels[level].position + levels[level].pivot_offset 
		var vitri2 = levels[level+1].position + levels[level+1].pivot_offset 
		draw_dashed_line(vitri1,vitri2, Color.hex(0x79B2A3FF), 9, 12, true)
	
	if Data.passed_level >= 0 and Data.passed_level < (levels.size() - 1):
		var vitri1 = levels[Data.passed_level].position + levels[Data.passed_level].pivot_offset 
		var vitri2 = levels[Data.passed_level+1].position + levels[Data.passed_level+1].pivot_offset 
		draw_dashed_line(vitri1,vitri2, Color.hex(0x8d4949FF), 9, 12, true)
