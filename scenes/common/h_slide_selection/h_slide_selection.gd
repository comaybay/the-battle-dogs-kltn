class_name HSlideSelection extends SubViewportContainer

var _items: Array[Selectable] 
func get_items() -> Array[Selectable]: return _items

var _selected_item: Selectable
var _hovered: bool = false

func _ready() -> void:
	mouse_entered.connect(func(): _hovered = true)
	mouse_exited.connect(func(): _hovered = false)

func setup(items: Array[Selectable], selected_item_index: int):
	_items = items
	for item in items:
		item.pressed.connect(_on_item_pressed.bind(item))
		var control := Control.new()
		control.custom_minimum_size = item.size
		item.resized.connect(func(): control.custom_minimum_size = item.size)
		item.focus_entered.connect(select_by_item.bind(item))
		control.add_child(item)
		%HBoxContainer.add_child(control)

	# wait for level boxes name to be loaded in (which will change the size of HBox)
	_selected_item = _items[selected_item_index]
	select.call_deferred(selected_item_index)
	
	size.y = items[0].size.y * 1.2
	%HBoxContainer.position.y = size.y * 0.2 * 0.5

func _on_item_pressed(item: Selectable):
	if _selected_item != item:
		select_by_item(item)

func select_by_item(item: Selectable) -> void:
	_selected_item.set_selected(false)
	var tween := create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_selected_item, "scale", Vector2(1, 1), 0.2)
	
	_selected_item = item
	_selected_item.set_selected(true)
	tween.tween_property(_selected_item, "scale", Vector2(1.1, 1.1), 0.2)
	
	tween.tween_property(%HBoxContainer, "position:x", _get_x_of(_selected_item), 0.5)

func select(index: int) -> void:
	select_by_item(_items[index])

func _get_x_of(level_box: Selectable):
	var box_position = level_box.get_parent().position + (level_box.size / 2)
	return -box_position.x + (size.x / 2)

var swiping = false
var swipe_mouse_start
var swipe_mouse_times = []
var swipe_mouse_positions = []

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		var index = _items.find(_selected_item)
		if index > 0:
			select(index - 1)
			
	elif event.is_action_pressed("ui_right"):
		var index = _items.find(_selected_item)
		if index < _items.size() - 1:
			select(index + 1)
			
func _input(ev: InputEvent):
	if swiping == false and not _hovered:
		return
	
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
