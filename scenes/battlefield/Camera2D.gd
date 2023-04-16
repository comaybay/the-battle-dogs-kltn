extends Camera2D

const ZOOM_SPEED = 3
const MOVE_SPEED = 900
const MIN_ZOOM = Vector2(0.25, 0.25)
const MAX_ZOOM = Vector2.ONE
@onready var half_viewport_size = get_viewport().size / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limit_left = -800 
	limit_right = 2000 
	position.x = (limit_left + limit_right) / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	position.x = clamp(position.x + MOVE_SPEED * direction * delta, limit_left + half_viewport_size.x, limit_right - half_viewport_size.x)  	
	print(position.x, limit_left)
	
	if Input.is_action_pressed("ui_zoomin"):
		zoom = zoom.lerp(MIN_ZOOM, ZOOM_SPEED * delta)
	elif Input.is_action_pressed("ui_zoomout"):
		zoom = zoom.lerp(MAX_ZOOM, ZOOM_SPEED * delta)
		
