class_name ChapterButton extends Selectable

signal chapter_entering

const ACCENT_COLOR: Color = 0xf5ed56ff
var _accent_stylebox: StyleBoxFlat

func _ready() -> void:
	mouse_exited.connect(_on_mouse_exited)
	_accent_stylebox = get_theme_stylebox("pressed").duplicate() as StyleBoxFlat
	_accent_stylebox.border_color = ACCENT_COLOR
	add_theme_stylebox_override("pressed", _accent_stylebox)
	
func setup(chapter_id: String, image: Texture2D) -> void:
	$TextureRect.texture = image
	$Label.text = tr("@CHAPTER_%s" % chapter_id)

func play_enter_chapter_animation() -> void:
	var tween := create_tween()
	var prev_value: int = -1
	
	tween.tween_method(func(value: int):
		if value == prev_value:
			return
		elif value % 2:
			add_theme_stylebox_override("focus", _accent_stylebox)
		else:
			remove_theme_stylebox_override("focus")
	, 0, 11, 0.75)
	
	await tween.finished

## avoid entering chapter while select chapter animation is running
var _first_click: bool = false
func _on_mouse_exited(): _first_click = false
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.double_click:
			_first_click = true
			
		elif event.double_click and _first_click:
			set_process_input(false)
			chapter_entering.emit()
			
			handle_selected()
			await play_enter_chapter_animation()
			get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")

func handle_selected() -> void:
	await play_enter_chapter_animation()
	get_tree().change_scene_to_file("res://scenes/dogbase/dogbase.tscn")
