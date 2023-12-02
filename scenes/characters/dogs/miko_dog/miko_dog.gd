class_name MikoDog extends BaseDog

const HIT_SFX: AudioStream = preload("res://scenes/characters/dogs/miko_dog/se_damage00.wav") 

## this value might change if miko dog is a cat
var ofuda_damage: int = 10

func _ready() -> void:
	super._ready()
	
	if not AudioPlayer.has_in_battle_sfx(HIT_SFX):
		AudioPlayer.add_in_battle_sfx(HIT_SFX, 20)
	
	get_FSM().state_entering.connect(_on_state_entering)
	
func _on_state_entering(state_name: String, data: Dictionary) -> void:
	if state_name != "AttackState":
		return

	var enemies = get_tree().get_nodes_in_group(
		 "cats" if character_type == Character.Type.DOG else "dogs"
	)
	
	if enemies.is_empty():
		data['attack_point'] = Vector2(global_position.x + attack_range * 2 * move_direction, global_position.y)
	else:
		data['attack_point'] = enemies.pick_random().global_position
