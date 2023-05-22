class_name DogTower extends StaticBody2D

signal zero_health

var health: int
var max_health: int

## position where effect for the tower should take place 
var effect_global_position: Vector2:
	get: return $Marker2D.global_position
	
func _ready() -> void:
	#TODO: increase health through upgrade
	max_health = 500
	
	health = max_health
	update_health_label()

func update_health_label():
	$HealthLabel.text = "%s/%s" % [health, max_health]

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
	
func spawn(dog_scene: PackedScene) -> void:
	var dog = dog_scene.instantiate()
	dog.global_position = global_position + Vector2(100, 0)
	get_tree().current_scene.add_child(dog)
