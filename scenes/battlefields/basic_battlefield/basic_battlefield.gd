class_name BasicBattlefield extends TwoTowersBattlefield

var TutorialDogScene: PackedScene = preload("res://scenes/battlefields/common/base_battlefield/battlefield_tutorial_dog/battlefield_tutorial_dog.tscn")

var _tutorial_dog: BattlefieldTutorialDog = null

## get theme of the battlefield
func get_theme() -> String: return _stage_data['theme']

func _ready() -> void:
	super()
	if (
		not Data.has_done_battlefield_basics_tutorial 
		or not Data.has_done_battlefield_boss_tutorial
		or not Data.has_done_battlefield_final_boss_tutorial
		or not Data.has_done_battlefield_rush
	):
		_tutorial_dog = TutorialDogScene.instantiate()
		_tutorial_dog.setup(cat_tower, dog_tower, $Camera2D, $Gui)
		$Gui.add_child(_tutorial_dog)

func _clean_up() -> void:
	super()
	if _tutorial_dog != null:
		_move_tutorial_dog()

## move the tutorial dog outside of gui
func _move_tutorial_dog():
	var canvas_layer: = CanvasLayer.new()
	canvas_layer.layer = 2
	add_child(canvas_layer)
	_tutorial_dog.reparent(canvas_layer)
