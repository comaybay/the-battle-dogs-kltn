class_name Battlefield extends Node2D

var stage_width: int
var cat_tower_max_health: int

func _enter_tree() -> void:
	var file = FileAccess.open("res://resources/battlefield_data/doggonamu.json", FileAccess.READ)
	var battlefield_data = JSON.parse_string(file.get_as_text())

	## TODO: load battlefield map data
	var stage_width_margin: int = 300;
	stage_width = battlefield_data['stage_width'] + stage_width_margin * 2
	cat_tower_max_health = battlefield_data['cat_tower_health']

func _ready() -> void:
	var half_viewport_size = get_viewport().size / 2
	$CatTower.position.x = stage_width - 500;
	$CatTower.position.y = -50
	$Land.position.x = stage_width / 2
	
	$Camera2D.position = Vector2(stage_width/2, -half_viewport_size.y)
