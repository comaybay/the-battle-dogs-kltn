extends Node

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
	
	
