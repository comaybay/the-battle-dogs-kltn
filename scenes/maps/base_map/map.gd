extends Control 

const LevelBox: PackedScene = preload("res://scenes/maps/base_map/stage_box/stage_box.tscn")

@export var location: String 

func _ready():
	%StoryTitle.text = tr("@STORY_%s" % Data.selected_story_id)
	%ChapterTitle.text = tr("@CHAPTER_%s" % Data.selected_chapter_id)
	%Location.text = tr(location)
	
	if (Data.dogs.size() > 1 or Data.skills.size() > 1) and not Data.has_done_map_tutorial:
		var TutorialDogScene: PackedScene = load("res://scenes/map/map_tutorial_dog/map_tutorial_dog.tscn")
		var tutorial_dog: MapTutorialDog = TutorialDogScene.instantiate()
		tutorial_dog.setup(%TeamSetupButton)
		%GUI.add_child(tutorial_dog)
	
	var levels = $Stages.get_children()

	for index in levels.size():
		var level: Level = levels[index]
		var prev_level: Level = levels[index - 1] if index > 0 else null
		var next_level: Level = levels[index + 1] if index < levels.size() - 1 else null 
		level.setup(tr("@LEVEL_%s_NAME" % (index + 1)), index, prev_level, next_level)
	
	var level_boxes: Array[Selectable] = []
	for level in levels.slice(0, Data.passed_level + 2):
		var level_box = LevelBox.instantiate()
		level_box.setup(level)
		level_boxes.append(level_box)
		
	%LevelChain.setup(level_boxes, Data.selected_level, true)
	
	%Tracker.setup(levels, %LevelChain, %MapSprite, %TouchArea)	
	%Dog.setup(levels[Data.selected_level], %Tracker)
	
	%GoBackButton.pressed.connect(_go_back_to_dog_base)
	%AttackButton.pressed.connect(_go_to_battlefield)
	%TeamSetupButton.pressed.connect(_go_to_team_setup)
	
	Data.chapter_last_level = get_tree().get_nodes_in_group("levels").size() - 1
	Data.save()

func _go_to_battlefield() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	
	var dobase_theme := AudioPlayer.get_current_music()
	AudioPlayer.stop_music(dobase_theme, true, true)
	
	get_tree().change_scene_to_file("res://scenes/battlefield/battlefield.tscn")
	
func _go_to_team_setup() -> void:
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/team_setup/team_setup.tscn")

func _go_back_to_dog_base() -> void:
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func _exit_tree() -> void:
	Data.save()
