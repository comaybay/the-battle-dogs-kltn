extends Node

const EnergyExpand: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")

func _ready() -> void:
	var effect: Node2D = EnergyExpand.instantiate()
	effect.setup("on_tower")
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	effect.global_position = get_tree().current_scene.get_node("DogTower").global_position
	effect_space.add_child(effect)
	$drum.play()
	var cats: Array[Node] = get_tree().get_nodes_in_group("cats")
	for cat in cats:
		cat.knockback()	
		var effect_on_cat: Node2D = EnergyExpand.instantiate()
		effect_on_cat.setup("on_cat")
		effect_on_cat.global_position = cat.global_position
		effect_space.add_child(effect_on_cat) 
	await get_tree().create_timer(3).timeout
	queue_free()
