extends Node2D

var health: int = 1000;

func take_damage(damage: int) -> void:
	health -= damage
	


