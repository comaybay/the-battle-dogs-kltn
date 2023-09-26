@tool
extends FSMState

# called when the state is activated
func enter(data: Dictionary):
	
	SilentWolf.configure({
	"api_key": "goumasbyHC39s9kdTRaOQ8nSC9Xtt8pJ37jLvOSg",
	"game_id": "YOUR_SILENTWOLF_GAME_ID",
	"log_level": 1
	})	
	SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/MainPage.tscn"
	}) 

# (optional) called when the state is deactivated
func exit():
	pass 
		
# (optional) equivalent to _process but only called when the state is active
func update(delta):
	pass 
	
# (optional) equivalent to _physics_process but only called when the state is active
func physics_update(delta):
	pass 

# (optional) equivalent of _input but only called when the state is active
func input(event: InputEvent):
	pass 
	
	

