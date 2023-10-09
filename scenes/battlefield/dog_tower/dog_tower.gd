class_name DogTower extends BaseDogTower

var _player_data: BattlefieldPlayerData

func _ready() -> void:
	var battlefield = get_tree().current_scene as Battlefield
	_player_data = battlefield.get_player_data()
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/dog_tower.png" % battlefield.get_theme())
	_setup_max_health()
	
func _setup_max_health() -> void:
	max_health = 500
	var health_upgrade = Data.passives.get('dog_tower_health')
	if health_upgrade != null:
		max_health = max_health * pow(1.5, health_upgrade['level'])
	health = max_health
	update_health_label()
	
func spawn(dog_id: String) -> BaseDog:
	$SpawnSound.play()
	
	var index = _player_data.team_dog_ids.find(dog_id)
	var dog := _player_data.team_dog_scenes[index].instantiate() as BaseDog
	get_tree().current_scene.add_child(dog)
	
	var offset_y = dog.global_position.y - dog.get_bottom_global_position().y
	dog.setup(global_position + Vector2(100, offset_y))
	
	dog_spawn.emit(dog)
	return dog
	
