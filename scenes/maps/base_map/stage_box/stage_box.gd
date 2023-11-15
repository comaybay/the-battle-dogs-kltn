class_name LevelBox extends Selectable

var level: Level
var stylebox_override: StyleBoxFlat
var color_override: Color = 0xcc3300FF
var _slide_selection: HSlideSelection

func _ready() -> void:
	stylebox_override = get_theme_stylebox("pressed").duplicate()
	pivot_offset = size / 2.0
	
func setup(level_node: Level) -> void:	
	level = level_node
	text = level.get_level_name()
	$Flag.visible = level.index <= Data.passed_level
	update_flag_position()
	resized.connect(update_flag_position)

func handle_local_focus_entered() -> void:	
	add_theme_color_override("font_color", color_override)
	add_theme_color_override("font_hover_color", color_override)
	add_theme_stylebox_override("normal", stylebox_override)
	add_theme_stylebox_override("hover", stylebox_override)
	
func handle_local_focus_exited() -> void:	
	remove_theme_color_override("font_color")
	remove_theme_color_override("font_hover_color")
	remove_theme_stylebox_override("normal")
	remove_theme_stylebox_override("hover")

func update_flag_position():
	$Flag.position.x = size.x - 35
	$Flag.position.y = size.y - 27


