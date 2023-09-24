@tool
class_name BaseCat extends Character

var is_boss: bool = false
@export var reward_money: int = 10
@export var allow_boss_effect: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super._ready()
	
	var power_scale = InBattle.get_cat_power_scale()
	damage *= power_scale
	health *= power_scale
	
	super._reready()
