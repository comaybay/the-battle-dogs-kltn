@tool
class_name BaseCat extends Character

@export var reward_money: int = 10

func _ready() -> void:
	super._ready()
	
	var power_scale = InBattle.get_cat_power_scale()
	damage *= power_scale
	health *= power_scale
