extends Node

const UpSprite: PackedScene = preload("res://scenes/skills/power_up/sprite.tscn")

@export var type = ["attack_cooldown", "speed", "damage"]
@export var up = 100
@export var time = 5
@export var scale = 1.1

func _ready() -> void:
	var power_up_upgrade = Data.skills.get('power_up')
	if power_up_upgrade != null:
		scale = scale + (0.1 * (power_up_upgrade['level'] - 1))
	
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	
	var dogs: Array[Node] = get_tree().get_nodes_in_group("dogs")
	for dog in dogs:
		dog.powerUp(type, scale, time) # health  attack_cooldown damage speed
		var effect_on_dog: Node2D = UpSprite.instantiate()
		effect_space.add_child(effect_on_dog) 
		effect_on_dog.setup(time, dog)
		effect_on_dog.global_position = dog.global_position 
	
	queue_free()

