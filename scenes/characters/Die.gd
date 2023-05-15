@tool
extends FSMState

# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.queue_free() 
	
	if character is BaseCat:
		InBattle.money += character.reward_money

	

