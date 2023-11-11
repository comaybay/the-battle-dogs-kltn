class_name HSlideSelection extends SubViewportContainer

var _items: Array[Selectable] 
func get_items() -> Array[Selectable]: return _items

var selected_item: Selectable
@onready var _sub_viewport_size = $SubViewport.size

func setup(items: Array[Selectable], selected_item_index: int):
	_items = items
	for item in items:
		item.pressed.connect(_on_item_pressed.bind(item))
		%HBoxContainer.add_child(item)

	
	# wait for level boxes name to be loaded in (which will change the size of HBox)
	selected_item = _items[selected_item_index]
	select.call_deferred(selected_item_index)

func _on_item_pressed(item: Selectable):
	if selected_item != item:
		select_by_item(item)

func select_by_item(item: Selectable) -> void:
	selected_item.set_selected(false)
	selected_item = item
	selected_item.set_selected(true)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(%HBoxContainer, "position:x", _get_x_of(selected_item), 0.5)

func select(index: int) -> void:
	select_by_item(_items[index])

func _get_x_of(level_box: Selectable):
	var box_position = level_box.position + (level_box.size / 2)
	return -box_position.x + (_sub_viewport_size.x / 2)

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
	return clamp(x, _get_x_of(_items[-1]), _get_x_of(_items[0]))
