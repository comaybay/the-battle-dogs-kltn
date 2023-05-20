class_name Battlefield extends Node2D

var VictoryGUI: PackedScene = preload("res://scenes/battlefield/victory_gui/victory_gui.tscn")

var stage_width: int

func _enter_tree() -> void:
	var battlefield_data = InBattle.load_battlefield_data()
	stage_width = battlefield_data['stage_width']
	
func _ready() -> void:
	InBattle.reset()
	6
	var half_viewport_size = get_viewport().size / 2
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width
	
	$CatTower.position.x = stage_width - 500;
	$CatTower.position.y = -50
	$DogTower.position.x = 500
	$DogTower.position.y = -50
	
	$Land.position.x = stage_width / 2.0
	
	$Camera2D.position = Vector2(0, -half_viewport_size.y)

	$CatTower.zero_health.connect(_show_win_ui)

func _process(delta: float) -> void:
	InBattle.update(delta)
	
func _show_win_ui():
	# set back to 1 in case user change game speed
	Engine.time_scale = 1
	
	$Camera2D.disable_camera_movement()
	$Gui.queue_free()
	add_child(VictoryGUI.instantiate())	
