extends Camera2D

const ZOOM_SPEED: float = 1.5
const MOVE_SPEED: int = 2500
const MAX_ZOOM := Vector2.ONE
const LAND_HEIGHT: int = 283
var min_zoom: Vector2

var _camera_control_buttons: CameraControlButtons
var viewport_size: Vector2
var half_viewport_size: Vector2
var _delta: float = 0

func setup(camera_control_buttons: CameraControlButtons):
	_camera_control_buttons = camera_control_buttons

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	half_viewport_size =  viewport_size / 2
	
	var parent :Node = get_parent()
	limit_left = 0
	limit_right = parent.stage_width
	limit_bottom = LAND_HEIGHT
	
	var min_zoom_scale:float = max(float(viewport_size.x) / parent.stage_width, 0.25) 
	min_zoom = Vector2(min_zoom_scale, min_zoom_scale) 

	var initial_zoom_scale = max(0.375, min_zoom_scale) 
	zoom = Vector2(initial_zoom_scale, initial_zoom_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_delta = delta
	
	# see if user press buttons / keynoard
	var left := int(_camera_control_buttons.is_move_left_on())
	var right := int(_camera_control_buttons.is_move_right_on())
	var direction := right - left
	
	position = get_screen_center_position()
	position.x = position.x + MOVE_SPEED * direction * delta  	
	position.y = limit_bottom - half_viewport_size.y
	position.y -= zoom.x * 200
	
	var zoom_in := int(_camera_control_buttons.is_zoom_in_on())
	var zoom_out := int(_camera_control_buttons.is_zoom_out_on())
	var zoom_dir := zoom_in - zoom_out
	handle_zoom(zoom_dir, delta)

func handle_zoom(direction: int, delta: float):
	zoom.x += zoom.x * ZOOM_SPEED * delta * direction
	zoom.y = zoom.x
	zoom = zoom.clamp(min_zoom, MAX_ZOOM)

func allow_user_input_camera_movement(state: bool) -> void:
	set_process(state)
