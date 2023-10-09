class_name OnlineDogTower extends BaseDogTower

enum Direction {LEFT_TO_RIGHT, RIGHT_TO_LEFT}

@export var direction: Direction

var _is_player_tower: bool
var _player_data: OnlineBattlefieldPlayerData

func setup(is_player_tower: bool, player_data: OnlineBattlefieldPlayerData):
	_is_player_tower = is_player_tower
	_player_data = player_data

func _ready() -> void:
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/dog_tower.png" % Steam.getLobbyData(SteamUser.lobby_id, "theme"))
	_setup_max_health()
	
func _setup_max_health() -> void:
	max_health =  int(Steam.getLobbyData(SteamUser.lobby_id, "max_health"))
	health = max_health
	update_health_label()

func spawn(dog_id: String) -> BaseDog:
	if _is_player_tower:
		$SpawnSound.play()
	
	var index = _player_data.team_dog_ids.find(dog_id)
	var dog := _player_data.team_dog_scenes[index].instantiate() as BaseDog
	
	if direction == Direction.LEFT_TO_RIGHT:
		get_tree().current_scene.add_child(dog)
		var offset_y = dog.global_position.y - dog.get_bottom_global_position().y
		dog.setup(global_position + Vector2(100, offset_y))
	else:
		# the dog in this case needs to move from right to left so it will act as a "Cat" 
		dog.character_type = Character.Type.CAT
		dog.get_character_animation_node().scale.x = -1
		dog.add_to_group("cats")
		get_tree().current_scene.add_child(dog)
		var offset_y = dog.global_position.y - dog.get_bottom_global_position().y
		dog.setup(global_position + Vector2(-100, offset_y))
	
	if _is_player_tower:
		dog.add_to_group("player_dogs")	
	else:
		dog.add_to_group("opponent_dogs")	
	
	dog_spawn.emit(dog)
	return dog
