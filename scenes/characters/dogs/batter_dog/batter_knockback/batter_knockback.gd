extends Node

const ENERGY_EXPAND_SCENE: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")

func setup(emitter: BaseDog) -> void:
	var effect: Node2D = ENERGY_EXPAND_SCENE.instantiate()
	effect.setup("on_emitter")
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	effect.global_position = emitter.get_center_global_position()
	effect_space.add_child(effect)
	var cats: Array[Node] = get_tree().get_nodes_in_group("cats")
	
	$DrumSound.play()
	
	for cat in cats:
		cat.knockback()	
		var effect_on_cat: Node2D = ENERGY_EXPAND_SCENE.instantiate()
		effect_on_cat.setup("on_cat")
		effect_on_cat.global_position = cat.global_position
		effect_space.add_child(effect_on_cat) 
		
	await $DrumSound.finished
	queue_free()
