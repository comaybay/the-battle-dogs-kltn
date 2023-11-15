class_name Stage extends Button

@export var stage_id: String 

var _stage_name: String
func get_stage_name(): return _stage_name  

## Acts as a doubly linked-list
var next_stage: Stage
var prev_stage: Stage
var index: int

var stylebox_override: StyleBoxFlat
	
func _ready() -> void:
	_stage_name = tr("@STAGE_%s" % stage_id)
	stylebox_override = get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0x960000FF)
	stylebox_override.bg_color = Color.hex(0xEE0000FF)
	
func setup(stage_index: int,  prev_stage_node: Stage, next_stage_node: Stage) -> void:
	$Flag.visible = stage_index <= Data.passed_stage
	
	if stage_index > Data.passed_stage + 1:
		disabled = true
		return
	
	prev_stage = prev_stage_node
	next_stage = next_stage_node
	index = stage_index
	pressed.connect(func(): set_selected(true))
	
func set_selected(selected: bool):
	if selected:
		add_theme_stylebox_override("normal", stylebox_override)
		Data.selected_battlefield_id = stage_id
		Data.selected_stage = index
	else:
		remove_theme_stylebox_override("normal")
	
