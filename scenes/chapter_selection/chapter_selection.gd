extends Control

const CHAPTER_BUTTON: PackedScene = preload("res://scenes/chapter_selection/chapter_button/chapter_button.tscn")

var main_chapters: Array[Selectable] = []
var character_chapters: Array[Selectable] = []
var is_main_chapter_focused := true

func _init() -> void:
	load_main_chapters()
	load_character_chapters()

func load_main_chapters() -> void:
	var dir_path := "res://resources/chapters/main_story"
	var dir := DirAccess.open(dir_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var index = 0
	while file_name != "":
		if file_name.get_extension() != "png":
			file_name = dir.get_next()
			continue
		
		var chapter_button: ChapterButton = CHAPTER_BUTTON.instantiate()
		var chapter_id = file_name.get_file().trim_suffix(".png")
		chapter_button.setup(chapter_id, load("%s/%s" % [dir_path, file_name]))
		chapter_button.chapter_entering.connect(func():
			Data.save_data['selected_main_story_chapter'] = index
			Data.save_data['selected_chapter_id'] = chapter_id
			Data.save()
		)
		main_chapters.append(chapter_button)
		file_name = dir.get_next()	
		index += 1
		
func load_character_chapters() -> void:
	var dir_path := "res://resources/chapters/character_stories"
	var dir := DirAccess.open(dir_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var index = 0
	while file_name != "":
		if file_name.get_extension() != "png":
			file_name = dir.get_next()
			continue
		
		var chapter_button: ChapterButton = CHAPTER_BUTTON.instantiate()
		var chapter_id = file_name.get_file().trim_suffix(".png")
		chapter_button.setup(chapter_id, load("%s/%s" % [dir_path, file_name]))
		chapter_button.chapter_entering.connect(func():
			Data.save_data['selected_character_story_chapter'] = index
			Data.save_data['selected_chapter_id'] = chapter_id
			Data.save()
		)
		character_chapters.append(chapter_button)
		file_name = dir.get_next()	
		index += 1
		
func _ready() -> void:
	%GoBackButton.pressed.connect(_go_to_dogbase)
	%MainChapters.setup(main_chapters, Data.save_data['selected_main_story_chapter'])
	%MainChapters.grab_focus()
	%CharacterChapters.setup(character_chapters, Data.save_data['selected_character_story_chapter'])
	%NavigationButton.pressed.connect(_navigate)

func _go_to_dogbase() -> void:
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func _navigate() -> void:
	if is_main_chapter_focused:
		_navigate_to_character_chapters()
	else:
		_navigate_to_main_chapters()

func _navigate_to_main_chapters() -> void:
	is_main_chapter_focused = true
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(%MarginContainer, "position:y", 0, 0.25)
	tween.tween_property(%NavigationButton, "scale:y", 1, 0.25)
	%MainChapters.grab_focus()
	%NavigationButton.set_activated(true)
	await tween.finished
	%NavigationButton.set_activated(false)
	
func _navigate_to_character_chapters() -> void:
	is_main_chapter_focused = false
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(%MarginContainer, "position:y", -510, 0.25)
	tween.tween_property(%NavigationButton, "scale:y", -1, 0.25)
	%CharacterChapters.grab_focus()
	%NavigationButton.set_activated(true)
	await tween.finished
	%NavigationButton.set_activated(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_navigate_to_character_chapters()
		
	elif event.is_action_pressed("ui_up"):
		_navigate_to_main_chapters()
