@tool
class_name TitanDog extends Character

# id used to retrive save infomation of a dog character
@export var name_id: String 

var level 

func store_setup(dog_tower: DogTower, player_data: BaseBattlefieldPlayerData):
	level = Data.selected_stage 
	setup(dog_tower.global_position + Vector2(500,0),1)

func setup(
		global_position: Vector2,
		dog_level: int,
		character_type: Character.Type = Character.Type.DOG,
		is_boss: bool = false
	) -> void:
	
	$FiniteStateMachine.change_state("MoveState")
	self.character_type = character_type
	_setup(global_position, is_boss)
	damage = 10 + 5 * level  
	health = health + health * level
	
	velocity.x = speed * move_direction 

func take_damage(ammount: int) -> void:
	super.take_damage(ammount)
	if health <= 0:
		$FiniteStateMachine.change_state("DieState")

	
func knockback(scale: float = 1):
	pass

func _on_attack_cooldown_timer_timeout():
	var characters := get_tree().get_nodes_in_group("cats")
	for character in characters:
		character.take_damage(damage)


