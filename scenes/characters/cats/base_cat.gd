@tool
class_name BaseCat extends Character

@export var reward_money: int = 10
@export var allow_boss_effect: bool = true

func _ready() -> void:
	super._ready()
	
	var power_scale = InBattle.get_cat_power_scale()
	damage *= power_scale
	max_health *= power_scale
	health = max_health
	
