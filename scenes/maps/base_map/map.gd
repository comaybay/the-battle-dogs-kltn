extends Control 

const STAGE_BOX_SCENE: PackedScene = preload("res://scenes/maps/base_map/stage_box/stage_box.tscn")

func _ready():
	%StoryTitle.text = tr("@STORY_%s" % Data.selected_story_id)
	%ChapterTitle.text = tr("@CHAPTER_%s" % Data.selected_chapter_id)
	%Location.text = tr("@LOCATION_%s" % Data.selected_chapter_id)
	
	if (Data.dogs.size() > 1 or Data.skills.size() > 1) and not Data.has_done_map_tutorial:
		var TutorialDogScene: PackedScene = load("res://scenes/map/map_tutorial_dog/map_tutorial_dog.tscn")
		var tutorial_dog: MapTutorialDog = TutorialDogScene.instantiate()
		tutorial_dog.setup(%TeamSetupButton)
		%GUI.add_child(tutorial_dog)
	
	var stages = $Stages.get_children()

	for index in stages.size():
		var stage: Stage = stages[index]
		var prev_stage: Stage = stages[index - 1] if index > 0 else null
		var next_stage: Stage = stages[index + 1] if index < stages.size() - 1 else null 
		stage.setup(tr("@STAGE_%s" % (index + 1)), index, prev_stage, next_stage)
	
	var stage_boxes: Array[Selectable] = []
	for stage in stages.slice(0, Data.passed_stage + 2):
		var stage_box = STAGE_BOX_SCENE.instantiate()
		stage_box.setup(stage)
		stage_boxes.append(stage_box)
		
	%StageChain.setup(stage_boxes, Data.selected_stage, true)
	
	%Tracker.setup(stages, %StageChain, %MapSprite, %TouchArea)	
	%Dog.setup(stages[Data.selected_stage], %Tracker)
	
	%GoBackButton.pressed.connect(_go_back_to_dog_base)
	%AttackButton.pressed.connect(_go_to_battlefield)
	%TeamSetupButton.pressed.connect(_go_to_team_setup)
	
	Data.chapter_last_stage = get_tree().get_nodes_in_group("stages").size() - 1
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
