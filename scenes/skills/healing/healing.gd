extends CharacterBody2D

@export var veloc = Vector2(0,900)
@export var heal = 100
var allCats = {}
var dog_tower

func _ready():
	$AnimationPlayer.play("move")
	dog_tower = get_tree().current_scene.get_node("DogTower")
	self.global_position = dog_tower.global_position + Vector2(0, -500)
	dog_tower.healing(1000)


func die() :
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.2).timeout
	queue_free()
