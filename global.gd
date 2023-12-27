extends Node

const TOUCH_EPSISLON: float = 2
var VIEWPORT_SIZE := Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"), 
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

# called when the state is activated
func _ready():
#	delete_score("yyyanhkhoa","fastest_time")
	SilentWolf.configure({
	"api_key": "goumasbyHC39s9kdTRaOQ8nSC9Xtt8pJ37jLvOSg",
	"game_id": "Thebattledogs",
	"log_level": 1
	})	
	SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/main.tscn"
	}) 
	
func is_host_OS_web() -> bool:
	return OS.get_name() == "WEB"

func is_host_OS_web_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")
	
func tr_format(message: StringName) -> String:
	var locale := TranslationServer.get_locale()
	TranslationServer.set_locale('format')
	var format: String = tr(message)
	TranslationServer.set_locale(locale)
	return format 

var _shared_timers: Dictionary = {}	
var _unused_timers: Array[DeltaTimer] = []
## wait a certain amount using a shared timers system. the returned timer is pausable by the scene tree [br]
## the signal also contains recover_delta parameter (delta time passed since signal is emited)
func wait(wait_time: float, recover_dela: float = 0.0) -> Signal:
	return _add_shared_timer(wait_time - recover_dela / Engine.time_scale).timeout

## wait a certain amount using a shared timers system. the returned timer is pausable by the scene tree
func wait_cancelable(wait_time: float, recover_dela: float = 0.0) -> WaitToken:
	var timer := _add_shared_timer(wait_time - recover_dela / Engine.time_scale)
	var token := WaitToken.new(timer)
	return token

func _add_shared_timer(wait_time: float) -> DeltaTimer:
	var id := Vector2(Engine.get_physics_frames(), snapped(wait_time, 0.00001))

	var timer: DeltaTimer
	
	if _shared_timers.has(id):
		timer = _shared_timers[id]
	elif not _unused_timers.is_empty():
		timer = _unused_timers.pop_back()
		timer.start(wait_time)
		_shared_timers[id] = timer
	else:
		timer = DeltaTimer.new()
		timer.start(wait_time)
		_shared_timers[id] = timer

	return timer

## return -1 or 1
func rand_sign() -> int:
	return sign(2 * randi_range(0, 1) - 1)

func rand_bool() -> bool:
	return bool(randi_range(0, 1))

func find_closest(node: Node2D, others: Array) -> Node2D:
	var closest: Node2D = null
	var min_distance: float = 1.79769e308
	
	for other in others:
		var distance := node.global_position.distance_squared_to(other.global_position)
		if min_distance > distance:
			min_distance = distance
			closest = other 
			
	return closest
	
var _timer_ids_to_be_unused: Array[Vector2] = []
func _physics_process(delta: float) -> void:
	for id: Vector2 in _shared_timers:
		var timer: DeltaTimer = _shared_timers[id]
		if timer.is_running():
			timer.physics_process(delta)
		elif timer.timeout.get_connections().is_empty() and timer.get_reference_count() <= 2: 
			_timer_ids_to_be_unused.append(id)
			
	for id: Vector2 in _timer_ids_to_be_unused: 
		_unused_timers.append(_shared_timers[id])
		_shared_timers.erase(id)
		
	_timer_ids_to_be_unused.clear()
