class_name LevelChain extends SubViewportContainer

const LevelBox: PackedScene = preload("res://scenes/map/level_chain/level_box.tscn")

var level_boxes: Array[LevelBox] 
@onready var viewport_size = $SubViewport.size
var mouse_pressed := false
var last_mouse_pos: Vector2
var selected_level_box: LevelBox
var is_mouse_entered: bool

func _ready() -> void:
	mouse_entered.connect(func(): is_mouse_entered = true)
	mouse_exited.connect(func(): is_mouse_entered = false)

func setup(levels: Array[Node]):
	for level in levels:
		var level_box = LevelBox.instantiate()
		level_box.setup(level)
		level_box.pressed.connect(_on_level_box_preesed.bind(level_box))
		$SubViewport/HBoxContainer.add_child(level_box)
		level_boxes.append(level_box)

	# wait for level boxes name to be loaded in (which will change the size of HBox)
	var first_box = level_boxes.front()
	var last_box = level_boxes.back() 
	selected_level_box = level_boxes[Data.selected_level]
	
	select.call_deferred(selected_level_box.level.index)

	
func _on_level_box_preesed(level_box: LevelBox):
	if selected_level_box != level_box:
		select(level_box.level.index)

func select(level_number: int):
	selected_level_box.set_selected(false)
	selected_level_box = level_boxes[level_number]
	selected_level_box.set_selected(true)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(%HBoxContainer, "position:x", _get_x_of(selected_level_box), 0.5)

func _get_x_of(level_box: LevelBox):
	var box_position = level_box.position + (level_box.size / 2)
	return -box_position.x + (viewport_size.x / 2)

var swiping = false
var swipe_mouse_start
var swipe_mouse_times = []
var swipe_mouse_positions = []

func _input(ev):
	if ev is InputEventMouseButton:
		if ev.pressed:
			swiping = true
			swipe_mouse_start = ev.position
			swipe_mouse_times = [Time.get_ticks_msec()]
			swipe_mouse_positions = [swipe_mouse_start]
		else:
			swipe_mouse_times.append(Time.get_ticks_msec())
			swipe_mouse_positions.append(ev.position)
			var source = Vector2(%HBoxContainer.position.x, %HBoxContainer.position.y)
			var idx = swipe_mouse_times.size() - 1
			var now = Time.get_ticks_msec()
			var cutoff = now - 100
			for i in range(swipe_mouse_times.size() - 1, -1, -1):
				if swipe_mouse_times[i] >= cutoff: idx = i
				else: break
			var flick_start = swipe_mouse_positions[idx]
			var flick_dur = min(0.3, (ev.position - flick_start).length() / 500)
			if flick_dur > 0.0:
				var tween = create_tween()
				var delta = ev.position - flick_start
				var target = source + delta * flick_dur * 25.0
				target.x = _x_clamp(target.x)
				
				tween.set_trans(Tween.TRANS_SINE)
				tween.set_ease(Tween.EASE_OUT)
				tween.tween_method((
					func(x): %HBoxContainer.position.x = x
				), source.x, target.x, flick_dur)
				tween.play()
			
			swiping = false
				
	elif swiping and ev is InputEventMouseMotion:
		%HBoxContainer.position.x += ev.relative.x
		%HBoxContainer.position.x = _x_clamp(%HBoxContainer.position.x)
		swipe_mouse_times.append(Time.get_ticks_msec())
		swipe_mouse_positions.append(ev.position)

func _x_clamp(x: float) -> float:
	return clamp(x, _get_x_of(level_boxes[-1]), _get_x_of(level_boxes[0]))
