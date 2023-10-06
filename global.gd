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
	sw_save_score_lw("yyyanhkhoa", 100 , "fastest_time")
	

func sw_save_score_lw(player_name: String,score:int, ldboard_name: String='main'):	
	var sw_result = await SilentWolf.Scores.get_scores_by_player(player_name, 10, ldboard_name).sw_get_player_scores_complete
	var sw_score = sw_result.scores	
	if score < sw_score[0]["score"]:		
		await SilentWolf.Scores.save_score(player_name, score , ldboard_name)


func delete_score(player_name: String, ldboard_name: String='main') -> void:	
	var sw_scores = await SilentWolf.Scores.get_scores(0,ldboard_name).sw_get_scores_complete
	for score in sw_scores.scores:		
		if score["player_name"] == player_name :
			print(score)
#			var sw_delete_score = await SilentWolf.Scores.delete_score(str(score["score_id"]),ldboard_name)
			
		
