extends Control

var done_tweening := true

func setup(dog_tower: BaseDogTower, player_data: BaseBattlefieldPlayerData):
	var item_ids: Array = player_data.team_item_ids
	var id_index := 0
	var action_number = 1
	
	for button in $FirstRow.get_children():		
		var name_id = item_ids[id_index]
		if name_id != null:
			button.setup(item_ids[id_index], "ui_item_%s" % action_number, true, dog_tower)
		
		id_index += 1	
		action_number += 1	
