extends Camera2D

const ZOOM_SPEED = 1.5
const MOVE_SPEED = 2500
const MAX_ZOOM = Vector2.ONE
const LAND_HEIGHT = 283
var min_zoom: Vector2

@onready var viewport_size = get_viewport().size
@onready var half_viewport_size = get_viewport().size / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent :Node = get_parent()
	limit_left = 0
	limit_right = parent.stage_width
	limit_bottom = LAND_HEIGHT
	
	var min_zoom_scale:float = max(float(viewport_size.x) / parent.stage_width, 0.25) 
	min_zoom = Vector2(min_zoom_scale, min_zoom_scale) 
	
	var initial_zoom_scale = max(0.4, min_zoom_scale) 
	zoom = Vector2(initial_zoom_scale, initial_zoom_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	position = get_screen_center_position()
	position.x = position.x + MOVE_SPEED * direction * delta  	
	position.y = limit_bottom - half_viewport_size.y 
	
	var zoom_dir = int(Input.is_action_pressed("ui_zoomin")) - int(Input.is_action_pressed("ui_zoomout"))
	zoom.x += zoom.x * ZOOM_SPEED * delta * zoom_dir
	zoom.y = zoom.x
	zoom = zoom.clamp(min_zoom, MAX_ZOOM)
		

func disable_camera_movement() -> void:
	set_process(false)
