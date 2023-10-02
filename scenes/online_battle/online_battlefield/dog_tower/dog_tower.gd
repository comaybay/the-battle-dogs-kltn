class_name OnlineDogTower extends DogTower

func _ready() -> void:
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/dog_tower.png" % Steam.getLobbyData(SteamUser.lobby_id, "theme"))
	
	health =  int(Steam.getLobbyData(SteamUser.lobby_id, "max_health"))
	
	update_health_label()
