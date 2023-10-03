class_name DogTower extends StaticBody2D

signal zero_health
signal dog_spawn(dog: BaseDog)

var health: int
var max_health: int

## position where effect for the tower should take place 
var effect_global_position: Vector2:
	get: return $Marker2D.global_position
	
func _ready() -> void:
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/dog_tower.png" % InBattle.battlefield_data['theme'])
	
	max_health = 500
	var health_upgrade = Data.passives.get('dog_tower_health')
	if health_upgrade != null:
		max_health = max_health * pow(1.5, health_upgrade['level'])
	
	health = max_health
	update_health_label()

func update_health_label():
	$HealthLabel.text = "%s/%s HP" % [health, max_health]

func take_damage(damage: int) -> void:
	if health <= 0:
		return
	
	health = max(health - damage, 0) 
	update_health_label()
	$AnimationPlayer.play("shake" if health > 0 else "fall")
	
	if health <= 0:
		for dog in get_tree().get_nodes_in_group("dogs"):
			dog.kill()
			
		zero_health.emit()
	

func healing(heal : int) -> void :
	var new_health = min(health + heal, max_health) 
	
	var tween := create_tween()
	tween.tween_method(func(value: float):
		health = value	
		update_health_label()
	, health, new_health, 2)
	
func spawn(dog_scene: PackedScene) -> BaseDog:
	$SpawnSound.play()
	
	var dog := dog_scene.instantiate() as BaseDog
	get_tree().current_scene.add_child(dog)
	var offset_y = dog.global_position.y - dog.get_bottom_global_position().y
	dog.setup(global_position + Vector2(100, offset_y))
	
	dog_spawn.emit(dog)
	return dog
	
