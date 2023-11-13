extends Control

const STORY_SCENE: PackedScene = preload("res://scenes/chapter_selection/story/story.tscn")

var _character_story_nodes: Array[Story] = []
var _selected_story_index: int = 0

func _init() -> void:
	load_stories()

func load_stories() -> void:
	var dir_path := "res://resources/stories"
	var dir := DirAccess.open(dir_path)
	for story_dir in dir.get_directories():
		var story: Story = STORY_SCENE.instantiate()
		story.setup(story_dir, get_chapter_image_paths(story_dir))
		_character_story_nodes.append(story)

func get_chapter_image_paths(story_dir: String) -> Array[String]:
	var chapter_ids: Array[String] = []
	var dir_path := "res://resources/stories/%s" % story_dir
	var dir := DirAccess.open(dir_path)
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.get_extension() != "png":
			file_name = dir.get_next()
			continue
			
		chapter_ids.append("%s/%s" % [dir_path, file_name])
		file_name = dir.get_next()	
	
	return chapter_ids
	
func _ready() -> void:
	%GoBackButton.pressed.connect(_go_to_dogbase)
	%NavigationButtonDown.pressed.connect(_navigate_down)
	%NavigationButtonUp.pressed.connect(_navigate_up)
	
	for story in _character_story_nodes:
		%StoryContainer.add_child(story)

	var selected_story = _character_story_nodes.filter(func(story: Story):
		return story.get_story_id() == Data.save_data['selected_story_id']
	)[0]
	
	_selected_story_index = _character_story_nodes.find(selected_story) 
	_update_navigation_ui()
	
	await get_tree().process_frame
	
	selected_story.grab_focus()
	%Camera2D.global_position.y = selected_story.global_position.y
	print(selected_story.global_position.y)
	print(selected_story.get_story_id())

func _go_to_dogbase() -> void:
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func _navigate_up() -> void:
	if _selected_story_index <= 0:
		return
		
	_selected_story_index -= 1
	
	var	story: Story = %StoryContainer.get_child(_selected_story_index)
	story.get_child(0).get_child(1).grab_focus()
	
	%NavigationButtonUp.set_activated(true)
	var	target_position_y: float = story.global_position.y
	await _story_transition(target_position_y)
	%NavigationButtonUp.set_activated(false)
	_update_navigation_ui()
	
func _navigate_down() -> void:
	var story_count: int = %StoryContainer.get_children().size()
	if _selected_story_index >= story_count - 1:
		return
		
	_selected_story_index += 1
	
	var	story: Story = %StoryContainer.get_child(_selected_story_index)
	story.get_child(0).get_child(1).grab_focus()
	
	%NavigationButtonDown.set_activated(true)
	var	target_position_y: float = story.global_position.y
	await _story_transition(target_position_y)
	%NavigationButtonDown.set_activated(false)
	_update_navigation_ui()

func _story_transition(target_position_y: float) -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(%Camera2D, "global_position:y", target_position_y, 0.25)
	await tween.finished

func _update_navigation_ui() -> void:
	var story_count: int = %StoryContainer.get_children().size()
	%NavigationButtonUp.visible = _selected_story_index > 0
	%NavigationButtonDown.visible = _selected_story_index < story_count - 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_navigate_down()
		
	elif event.is_action_pressed("ui_up"):
		_navigate_up()
