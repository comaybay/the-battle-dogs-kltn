class_name OnlineDogTowerLeft extends DogTower

var _is_player_tower: bool

func setup(is_player_tower: bool):
	_is_player_tower = is_player_tower

func _ready() -> void:
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/dog_tower.png" % Steam.getLobbyData(SteamUser.lobby_id, "theme"))
	
	max_health =  int(Steam.getLobbyData(SteamUser.lobby_id, "max_health"))
	health = max_health
	
	update_health_label()

func spawn(dog_scene: PackedScene) -> BaseDog:
	if _is_player_tower:
		$SpawnSound.play()
	
	var dog := dog_scene.instantiate() as BaseDog
	get_tree().current_scene.add_child(dog)
	var offset_y = dog.global_position.y - dog.get_bottom_global_position().y
	dog.setup(global_position + Vector2(100, offset_y))
	
	dog_spawn.emit(dog)
	return dog
	
