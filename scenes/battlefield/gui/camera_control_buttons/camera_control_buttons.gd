class_name CameraControlButtons extends HBoxContainer

## velocity to move camera when user flick the screen
var flick_velocity: float = 0
var _drag_relative_x: float = 0

## screen dragged, used for mocing camera to the dragged position 
signal dragged(relative: float)

func is_move_left_on() -> bool:
	return _is_on($MoveLeft/AnimationPlayer)

func is_move_right_on() -> bool:
	return _is_on($MoveRight/AnimationPlayer)

func is_zoom_out_on() -> bool:
	return _is_on($ZoomOut/AnimationPlayer)

func is_zoom_in_on() -> bool:
	return _is_on($ZoomIn/AnimationPlayer)

func _is_on(anim_player: AnimationPlayer) -> bool:
	return anim_player.current_animation == "on"	

var _scroll_up: bool = false
var _scroll_down: bool = false

func _ready() -> void:
	$MoveRight.button_down.connect(func(): $MoveRight/AnimationPlayer.play("on"))
	$MoveRight.button_up.connect(func(): $MoveRight/AnimationPlayer.play("off"))
	
	$ZoomOut.button_down.connect(func(): $ZoomOut/AnimationPlayer.play("on"))
	$ZoomOut.button_up.connect(func(): $ZoomOut/AnimationPlayer.play("off"))
	
	$ZoomIn.button_down.connect(func(): $ZoomIn/AnimationPlayer.play("on"))
	$ZoomIn.button_up.connect(func(): $ZoomIn/AnimationPlayer.play("off"))
	
	$Timer.timeout.connect(_stop_scroll)

func _stop_scroll():
	_scroll_up = false
	_scroll_down = false
	$ZoomIn/AnimationPlayer.play("off")
	$ZoomOut/AnimationPlayer.play("off")
	
func is_dragging() -> bool: return not is_zero_approx(_drag_relative_x) 
	
func _process(delta: float) -> void:
	var is_controlling: bool = (
		Input.is_action_pressed("ui_left") or $MoveLeft.button_pressed
		or Input.is_action_pressed("ui_right") or $MoveRight.button_pressed
	)
	## prioritize any other user inputs over touch inputs
	if is_controlling:
		flick_velocity = 0
		_drag_relative_x = 0
		
	$MoveLeft/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_left") 
		or $MoveLeft.button_pressed
		or flick_velocity < 0 
		or _drag_relative_x > 0
		else "off"
	)
	$MoveRight/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_right") 
		or $MoveRight.button_pressed 
		or flick_velocity > 0
		or _drag_relative_x < 0
		else "off"
	)

	$ZoomOut/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_zoomout") or _scroll_down or $ZoomOut.button_pressed else "off"
	)
	$ZoomIn/AnimationPlayer.play(
		"on" if Input.is_action_pressed("ui_zoomin") or _scroll_up or $ZoomIn.button_pressed else "off"
	)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_scroll_up = true
		_scroll_down = false
		$ZoomIn/AnimationPlayer.play("on")
		$ZoomOut/AnimationPlayer.play("off")
		$Timer.start()
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_scroll_down = true
		_scroll_up = false
		$ZoomOut/AnimationPlayer.play("on")
		$ZoomIn/AnimationPlayer.play("off")
		$Timer.start()
		
	
## mobile camera control
var swiping = false
var swipe_mouse_start
var swipe_mouse_times = []
var swipe_mouse_positions = []

func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		if ev.pressed:
			swiping = true
			flick_velocity = 0
			swipe_mouse_start = ev.position
			swipe_mouse_times = [Time.get_ticks_msec()]
			swipe_mouse_positions = [swipe_mouse_start]
		else:
			swipe_mouse_times.append(Time.get_ticks_msec())
			swipe_mouse_positions.append(ev.position)
			var source = position
			var idx = swipe_mouse_times.size() - 1
			var now = Time.get_ticks_msec()
			var cutoff = now - 100
			for i in range(swipe_mouse_times.size() - 1, -1, -1):
				if swipe_mouse_times[i] >= cutoff: idx = i
				else: break
			var flick_start = swipe_mouse_positions[idx]
			var flick_dur = min(0.3, (ev.position - flick_start).length() / 500)
			if flick_dur > 0.0:
				var delta = flick_start - ev.position 
				var target = source + delta * flick_dur * 25.0
				flick_velocity = (target.x - position.x) / flick_dur
			else:
				flick_velocity = 0
			
			swiping = false
			_drag_relative_x = 0
				
	elif swiping and ev is InputEventMouseMotion:
		dragged.emit(ev.relative.x)
		_drag_relative_x = ev.relative.x
		swipe_mouse_times.append(Time.get_ticks_msec())
		swipe_mouse_positions.append(ev.position)
		
		## stop button from active if drag stopped
		await get_tree().create_timer(0.1, false).timeout
		if _drag_relative_x == ev.relative.x:
			_drag_relative_x = 0
