extends Control 

func _ready():
	var levels = $Khung/map/AllLevel/Node.get_children()

	for index in levels.size():
		var level: Level = levels[index]
		var prev_level: Level = levels[index - 1] if index > 0 else null
		var next_level: Level = levels[index + 1] if index < levels.size() - 2 else null 
		level.setup(index, prev_level, next_level)
	
	%LevelChain.setup(levels.slice(0, Data.passed_level + 2))
	%Tracker.setup(levels, %LevelChain, %MapSprite, %TouchArea)	
	%Dog.setup(levels[Data.selected_level], %Tracker)

func _on_nut_tan_cong_pressed():
	InBattle.battlefield_id = Data.selected_battlefield_id
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/battlefield/battlefield.tscn")
	
func _on_doi_doi_hinh_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/selectCharacter/selectCharacter.tscn")

func _on_quay_lai_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")

func _exit_tree() -> void:
	Data.save()
