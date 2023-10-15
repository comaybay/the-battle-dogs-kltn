extends Node

const EXPLOSION_SCENE: PackedScene = preload("res://scenes/characters/dogs/batter_dog/explosion/batter_dog_explosion.tscn") 

func setup(emitter: BaseDog) -> void:
	var destination_x = get_tree().current_scene.get_stage_width() + BaseBattlefield.TOWER_MARGIN * 2
	var explosion_position := Vector2(emitter.global_position.x + 200, emitter.get_bottom_global_position().y)

	await get_tree().create_timer(0.3, false).timeout
	
	while explosion_position.x <= destination_x:
		await get_tree().create_timer(0.15, false).timeout
		var explosion: BatterDogExplosion = EXPLOSION_SCENE.instantiate()
		explosion.setup(explosion_position, emitter.damage / 10, emitter.move_direction)
		get_tree().current_scene.get_node("EffectSpace").add_child(explosion)
		explosion_position.x += 400 * emitter.move_direction

	queue_free()
