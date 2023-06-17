extends Node2D

@export var veloc = Vector2(0,900)
@export var heal = 250
var allCats = {}
var dog_tower

func _ready():
	var healing_upgrade = Data.skills.get('healing')
	if healing_upgrade != null:
		heal = heal + (heal * 2 * (healing_upgrade['level'] - 1))
		
	dog_tower = get_tree().current_scene.get_node("DogTower")
	self.global_position = dog_tower.global_position + Vector2(0, -500)
	
	dog_tower.healing(1000)
	await $AudioStreamPlayer.finished
	die()

func die() :
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()
