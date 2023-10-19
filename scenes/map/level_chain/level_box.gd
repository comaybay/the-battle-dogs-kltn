class_name LevelBox extends Button

var level: Level
var stylebox_override: StyleBoxFlat
var color_override: Color = 0xcc3300FF

func _ready() -> void:
	stylebox_override = get_theme_stylebox("pressed").duplicate()
	pivot_offset = size / 2.0

func setup(level_node: Level) -> void:	
	level = level_node
	text = level.get_level_name()
	$Flag.visible = level.index <= Data.passed_level
	update_flag_position()
	resized.connect(update_flag_position)

func set_selected(selected: bool) -> void:
	var tween = create_tween()
	var scale_value = Vector2(1.1, 1.1) if selected else Vector2(1, 1)
	tween.tween_property(self, "scale", scale_value, 0.2)
	
	if selected:
		add_theme_color_override("font_color", color_override)
		add_theme_color_override("font_hover_color", color_override)
		add_theme_stylebox_override("normal", stylebox_override)
		add_theme_stylebox_override("hover", stylebox_override)
	else:
		remove_theme_color_override("font_color")
		remove_theme_color_override("font_hover_color")
		remove_theme_stylebox_override("normal")
		remove_theme_stylebox_override("hover")

func update_flag_position():
	$Flag.position.x = size.x - 35


var _pressed: bool = false
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_pressed = event.pressed
		
		if not _pressed:
			disabled = false
		
	if _pressed and event is InputEventMouseMotion:
		disabled = true
