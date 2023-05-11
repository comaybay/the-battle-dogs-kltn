extends StaticBody2D

var health: int
var max_health: int

func _ready() -> void:
	var parent: Battlefield = get_parent()
	max_health = parent.cat_tower_max_health
	health = max_health
	update_health_label()

func update_health_label():
	$HealthLabel.text = "%s/%s" % [health, max_health]

func take_damage(damage: int) -> void:
	health -= damage
	update_health_label()
	$AnimationPlayer.play("shake")

func spawn(cat_scene: PackedScene) -> void:
	var cat = cat_scene.instantiate()
	cat.global_position = global_position - Vector2(100, 0)
	get_tree().current_scene.add_child(cat)
			
