@tool
class_name BaseCat extends Character

var is_boss: bool = false
@export var reward_money: int = 10
@export var allow_boss_effect: bool = true

func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return
		
	var battlefield := get_tree().current_scene as Battlefield
	var power_scale = battlefield.get_cat_power_scale()
	damage *= power_scale
	health *= power_scale
	
	super._reready()
