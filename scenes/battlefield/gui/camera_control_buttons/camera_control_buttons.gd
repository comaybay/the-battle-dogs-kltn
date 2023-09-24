class_name CameraControlButtons extends HBoxContainer

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
	
var point_x: float
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_middle_mouse"):
		point_x = get_viewport().get_mouse_position().x

	if Input.is_action_pressed("ui_middle_mouse"):
		var current_x := get_viewport().get_mouse_position().x
		$MoveLeft/AnimationPlayer.play("on" if current_x < point_x else "off")
		$MoveRight/AnimationPlayer.play("on" if current_x > point_x else "off")
	else:
		$MoveLeft/AnimationPlayer.play(
			"on" if Input.is_action_pressed("ui_left") or $MoveLeft.button_pressed else "off"
		)
		$MoveRight/AnimationPlayer.play(
			"on" if Input.is_action_pressed("ui_right") or $MoveRight.button_pressed else "off"
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

func _stop_scroll():
	_scroll_up = false
	_scroll_down = false
	$ZoomIn/AnimationPlayer.play("off")
	$ZoomOut/AnimationPlayer.play("off")
	

