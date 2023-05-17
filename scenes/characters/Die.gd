@tool
extends FSMState

# called when the state is activated
func enter(_data: Dictionary) -> void:
	$Die.play()
	await get_tree().create_timer(4.0).timeout
	character.queue_free() 
	
	if character is BaseCat:
		InBattle.money += character.reward_money

	

