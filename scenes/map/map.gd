extends Control 

const LevelBox: PackedScene = preload("res://scenes/map/level_box/level_box.tscn")

func _ready():
	if (Data.dogs.size() > 1 or Data.skills.size() > 1) and not Data.has_done_map_tutorial:
		var TutorialDogScene: PackedScene = load("res://scenes/map/map_tutorial_dog/map_tutorial_dog.tscn")
		var tutorial_dog: MapTutorialDog = TutorialDogScene.instantiate()
		tutorial_dog.setup(%TeamSetupButton)
		%GUI.add_child(tutorial_dog)
	
	var levels = $Khung/map/AllLevel/Node.get_children()

	for index in levels.size():
		var level: Level = levels[index]
		var prev_level: Level = levels[index - 1] if index > 0 else null
		var next_level: Level = levels[index + 1] if index < levels.size() - 1 else null 
		level.setup(tr("@LEVEL_%s_NAME" % (index + 1)), index, prev_level, next_level)
	
	
	var level_boxes: Array[Selectable] = []
	for level in levels:
		var level_box = LevelBox.instantiate()
		level_box.setup(level)
		level_boxes.append(level_box)
		
	%LevelChain.setup(level_boxes, Data.selected_level)
	
	%Tracker.setup(levels, %LevelChain, %MapSprite, %TouchArea)	
	%Dog.setup(levels[Data.selected_level], %Tracker)
	
	%GoBackButton.pressed.connect(_go_back_to_dog_base)

func _on_nut_tan_cong_pressed() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	
	var dobase_theme := AudioPlayer.get_current_music()
	AudioPlayer.stop_music(dobase_theme, true, true)
	
	get_tree().change_scene_to_file("res://scenes/battlefield/battlefield.tscn")
	
func _on_nut_doi_hinh_pressed() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/team_setup/team_setup.tscn")

func _go_back_to_dog_base() -> void:
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func _exit_tree() -> void:
	Data.save()
