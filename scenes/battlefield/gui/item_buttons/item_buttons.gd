extends Control

var done_tweening := true

func _ready() -> void:
	var name_ids: Array = Data.selected_team['item_ids']
	var id_index := 0
	var action_number = 1
	
	for button in $FirstRow.get_children():		
		var name_id = name_ids[id_index]
		if name_id != null:
			button.setup(name_ids[id_index], "ui_item_%s" % action_number, true)
		
		id_index += 1	
		action_number += 1
		
