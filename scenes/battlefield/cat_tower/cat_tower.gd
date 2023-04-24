extends Node2D

var health: int = 1000
var max_health: int = 1000

func _ready() -> void:
	update_health_label()

func update_health_label():
	$HealthLabel.text = "%s/%s" % [health, max_health]

func take_damage(damage: int) -> void:
	health -= damage
	update_health_label()
	$AnimationPlayer.play("shake")
	


