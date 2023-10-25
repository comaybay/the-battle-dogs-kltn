extends Node

const TOUCH_EPSISLON: float = 2

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
	
