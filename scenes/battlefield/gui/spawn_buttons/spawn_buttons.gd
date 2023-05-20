extends Control

var done_tweening := true

func _ready() -> void:
	var name_ids: Array = Data.selected_team['dog_ids']
	var id_index := 0
	var action_number = 1
		
	for button in $FirstRow.get_children():
		var name_id = name_ids[id_index]
		if name_id != null:
			button.setup(name_ids[id_index], "ui_spawn_%s" % action_number, true)
		
		id_index += 1	
		action_number += 1

	action_number = 1		
	for button in $SecondRow.get_children():
		var name_id = name_ids[id_index]
		if name_id != null:
			button.setup(name_ids[id_index], "ui_spawn_%s" % action_number, false)
		
		id_index += 1	
		action_number += 1
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_switch_row") and done_tweening:
		var back_row = get_child(0)
		var front_row = get_child(1)
		
		for button in front_row.get_children():
			button.set_active(false)

		for button in back_row.get_children():
			button.set_active(true)

		move_child(back_row, 1)
		
		var tween = create_tween()
		tween.set_parallel(true).set_trans(Tween.TRANS_CUBIC)
		done_tweening = false
		tween.tween_property(front_row, "position", back_row.position, 0.2)
		tween.tween_property(back_row, "position", front_row.position, 0.2)
		tween.finished.connect(func(): done_tweening = true)
