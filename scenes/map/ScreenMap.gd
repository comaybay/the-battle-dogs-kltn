extends Node2D

@export var level_now = 3

var game_data

func _ready():
	game_data = Data.save_data
	
	var levels := $Node.get_children()

	for index in levels.size():
		var level: Level = levels[index]
		var prev_level: Level = levels[index - 1] if index > 0 else null
		var next_level: Level = levels[index + 1] if index < levels.size() - 2 else null 
		level.setup(index, prev_level, next_level)
		
	$Tracker.setup(levels, $MapSprite)
	$Dog.setup(levels[Data.selected_level], $Tracker)
	
