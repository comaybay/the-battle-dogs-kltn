class_name Level extends Button

@export var level_name: String 
@export var battlefield_id: String 

## Acts as a doubly linked-list
var next_level: Level
var prev_level: Level
var index: int

var stylebox_override: StyleBoxFlat
	
func _ready() -> void:
	stylebox_override = get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0x960000FF)
	stylebox_override.bg_color = Color.hex(0xEE0000FF)
	
func setup(level_index: int,  prev_level_node: Level, next_level_node: Level) -> void:
	$Flag.visible = level_index <= Data.passed_level
	
	if level_index > Data.passed_level + 1:
		disabled = true
		return
	
	prev_level = prev_level_node
	next_level = next_level_node
	index = level_index
	pressed.connect(func(): set_selected(true))
	
func set_selected(selected: bool):
	if selected:
		add_theme_stylebox_override("normal", stylebox_override)
		Data.selected_battlefield_id = battlefield_id
		Data.selected_level = index
	else:
		remove_theme_stylebox_override("normal")
	
