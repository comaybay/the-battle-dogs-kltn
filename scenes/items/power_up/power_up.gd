extends BaseSkill

const UpSprite: PackedScene = preload("res://scenes/skills/power_up/sprite.tscn")

const DURATION: float = 5

func setup(skill_user: Character.Type) -> void:
	var level := InBattle.get_skill_level('power_up', skill_user)
	var power_scale: float = 1 + (0.1 * level)
	
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	
	var characters := (
		get_tree().get_nodes_in_group("dogs") if skill_user == Character.Type.DOG else
		get_tree().get_nodes_in_group("cats")
	)
		
	for character in characters:
		character.set_multiplier(character.MultiplierTypes.SPEED, power_scale)
		character.set_multiplier(character.MultiplierTypes.DAMAGE, power_scale)
		character.set_multiplier(character.MultiplierTypes.ATTACK_SPEED, power_scale)
		character.set_multiplier(character.MultiplierTypes.DAMAGE_TAKEN, 1 / power_scale)
		
		var effect_on_character: Node2D = UpSprite.instantiate()
		effect_space.add_child(effect_on_character) 
		effect_on_character.setup(DURATION, character)
		
	await get_tree().create_timer(DURATION, false).timeout
	
	for character in characters:
		if character != null: # if character not dead
			character.reset_multipliers()
	
	if $AudioStreamPlayer.playing:
		await $AudioStreamPlayer.finished
	
	queue_free()

