@tool
class_name MikoDog extends BaseDog

## this value might change if miko dog is a cat
var ofuda_damage: int = 10

func _ready() -> void:
	super._ready()
	

	
	get_FSM().state_entering.connect(_on_state_entering)
	
func _on_state_entering(state_name: String, data: Dictionary) -> void:
	if InBattle.in_request_mode or state_name != "AttackState":
		return

	var enemies = get_tree().get_nodes_in_group(
		 "cats" if character_type == Character.Type.DOG else "dogs"
	)
	
	if enemies.is_empty():
		data['attack_point'] = Vector2(global_position.x + attack_range * 2 * move_direction, global_position.y)
	else:
		data['attack_point'] = enemies.pick_random().global_position
