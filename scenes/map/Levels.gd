extends Node2D

@onready var levels = get_children()	

func get_selected_level() -> Level:
	var index := levels.find(func(level: Level): level.battlefield_id == Data.selected_battlefield_id) 
	return null if index < 0 else levels[index] 

func _draw() -> void:
	for level in Data.passed_level :
		var vitri1 = levels[level].position + levels[level].pivot_offset 
		var vitri2 = levels[level+1].position + levels[level+1].pivot_offset 
		
		draw_dashed_line(vitri1,vitri2, Color.hex(0x79B2A3FF), 9, 12, true)
	var vitri1 = levels[Data.passed_level].position + levels[Data.passed_level].pivot_offset 
	var vitri2 = levels[Data.passed_level+1].position + levels[Data.passed_level+1].pivot_offset 
	draw_dashed_line(vitri1,vitri2, Color.BLACK, 9, 12, true)
