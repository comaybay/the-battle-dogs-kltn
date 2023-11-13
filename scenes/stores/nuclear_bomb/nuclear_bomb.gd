extends CharacterBody2D

var _damage = 10000
var set_launch = 0
var launch_up = Vector2(0, 0)

func setup(dog_tower: DogTower):
	self.global_position = Vector2(1500, -1000)
	$bom_animation/Control_rocket.global_position = dog_tower.global_position + Vector2(550, -400)
#	$bom_animation/rocket.global_position = dog_tower.global_position + Vector2(700, -200)
	print( dog_tower.global_position)
	velocity = Vector2(0, -500)
	
#	launch()

func _physics_process(delta: float) -> void:
	
	if set_launch == 2 :
		var collision = move_and_collide(launch_up * delta)
	if set_launch == 1 :
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			var all_character = get_tree().get_nodes_in_group("characters")
			for charat in all_character:
				charat.kill()
			die()

func launch() :
	Data.store["nuclear_bomb"].amount -= 1
	launch_up = Vector2(0, 500)
	set_launch = 1
	$AnimationPlayer.play("launch")
	await get_tree().create_timer(4, false).timeout
#	$Sprite2D.visible = true
	
#	$bom_animation/rocket.visible = false
	set_launch = 2
	
func die():
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.7, false).timeout
	queue_free()


func _on_control_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("asddddd")
		launch()
