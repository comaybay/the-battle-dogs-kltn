class_name BaseStore extends Node2D

## skill_user: the group that uses this skill.  
## Determine wether this skill is used by player tower or by enemy tower
func setup(skill_user: Character.Type) -> void:
	push_error("ERRORS: setup(store_user: StoreUser, direction: Direction) not implemented")
