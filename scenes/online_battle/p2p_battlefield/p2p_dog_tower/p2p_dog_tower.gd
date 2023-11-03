class_name P2PDogTower extends BaseDogTower

enum Direction { LEFT_TO_RIGHT, RIGHT_TO_LEFT }

@export var direction: Direction

var _is_player_tower: bool
func is_player_tower() -> bool: return _is_player_tower

var _player_data: P2PBattlefieldPlayerData
func get_player_data() -> P2PBattlefieldPlayerData: return _player_data

func setup(is_player_tower: bool, player_data: P2PBattlefieldPlayerData):
	_is_player_tower = is_player_tower
	_player_data = player_data

func _ready() -> void:
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/dog_tower.png" % Steam.getLobbyData(SteamUser.lobby_id, "theme"))
	
	zero_health.connect(kill_all_dogs, CONNECT_ONE_SHOT)	
	
	_setup_max_health()
	
func kill_all_dogs() -> void:
	for dog in get_tree().get_nodes_in_group(
		"dogs" if direction == Direction.LEFT_TO_RIGHT else "cats"
	):
		dog.kill()
	
func _setup_max_health() -> void:
	max_health = int(SteamUser.get_lobby_data(CustomBattlefieldSettings.TYPE_DOG_TOWER_HEALTH))
	health = max_health
	update_health_label()

func spawn(dog_id: String) -> BaseDog:
	if _is_player_tower:
		$SpawnSound.play()
	
	var index = _player_data.team_dog_ids.find(dog_id)
	var dog := _player_data.team_dog_scenes[index].instantiate() as BaseDog
	
	if direction == Direction.LEFT_TO_RIGHT:
		InBattle.get_battlefield().add_child(dog)
		var offset_y = dog.global_position.y - dog.get_bottom_global_position().y - 1
		dog.setup(global_position + Vector2(100, offset_y))
	else:
		# the dog in this case needs to move from right to left so it will act as a "Cat" 
		dog.character_type = Character.Type.CAT
		dog.remove_from_group("dogs")	
		dog.add_to_group("cats")	
		dog.get_character_animation_node().scale.x = -1
		InBattle.get_battlefield().add_child(dog)
		var offset_y = dog.global_position.y - dog.get_bottom_global_position().y - 1
		dog.setup(global_position + Vector2(-100, offset_y))
	
	if not _is_player_tower:
		# this group is used to determine the enemies RELATIVE to the player
		dog.add_to_group("enemies")	
	
	dog_spawn.emit(dog)
	return dog

func use_skill(skill_id: String) -> BaseSkill:
	$SpawnSound.play()
	
	var index = _player_data.team_skill_ids.find(skill_id)
	var skill := _player_data.team_skill_scenes[index].instantiate()
	InBattle.get_battlefield().add_child(skill)
	
	# tower on the right side will act as "CAT" skill user
	var skill_user := (
		Character.Type.DOG if direction == Direction.LEFT_TO_RIGHT 
		else Character.Type.CAT
	)
	
	skill.setup(skill_user)
	return skill

## p2p method to set health in client peer
func set_health(health: int) -> void:
	self.health = health
	update_health_label()
	if health <= 0:
		$AnimationPlayer.play("fall")
