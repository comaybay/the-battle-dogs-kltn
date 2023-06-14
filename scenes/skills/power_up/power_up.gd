extends Node

const UpSprite: PackedScene = preload("res://scenes/skills/power_up/sprite.tscn")

@export var type = ["attack_cooldown", "speed", "damage"]
@export var up = 100
@export var time = 5

func _ready() -> void:
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	
	var dogs: Array[Node] = get_tree().get_nodes_in_group("dogs")
	for dog in dogs:
		dog.powerUp(type, 1.5 ,time) # health  attack_cooldown damage speed
		var effect_on_dog: Node2D = UpSprite.instantiate()
		effect_space.add_child(effect_on_dog) 
		effect_on_dog.setup(time, dog)
		effect_on_dog.global_position = dog.global_position 
	
	queue_free()

