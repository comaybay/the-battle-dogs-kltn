extends CharacterBody2D

@export var dame = 50
var count = 0
var object
var speed = 500
func _ready():
	pass

func target(cat) :
	object = cat.global_position

func _physics_process(delta):
	var direction = (object - global_position).normalized()
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		var character = collision.get_collider()
		if character: # va cham all			
			if (character is BaseCat) and (count == 0) : # va cham BaseCat (all cat)
				count += 1
				character.take_damage(dame)
				queue_free()
		queue_free()
	
