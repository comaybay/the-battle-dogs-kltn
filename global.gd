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

var _timers: Dictionary = {}	
## wait a certain amount using a shared timers system. the returned timer is pausable by the scene tree
func wait(wait_time: float) -> Signal:
	var id := Vector2(Time.get_ticks_msec(), wait_time)

	if not _timers.has(id):
		var timer := get_tree().create_timer(wait_time, false)
		_timers[id] = get_tree().create_timer(wait_time, false)
		timer.timeout.connect(func(): _timers.erase(id), CONNECT_ONE_SHOT)

	return _timers[id].timeout
