class_name BaseDogTower extends StaticBody2D

signal zero_health
signal dog_spawn(dog: BaseDog)

var health: int
var max_health: int

## position where effect for the tower should take place 
var effect_global_position: Vector2:
	get: return $Marker2D.global_position

func spawn(dog_id: String) -> BaseDog:
	push_error("ERROR: spawn(dog_id: String) not implemented")
	return null
		
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
