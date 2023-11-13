extends CharacterBody2D

var _damage = 10000
var set_launch = 0
var launch_up = Vector2(0, 0)
var launch_down = Vector2(0, 0)
var cat_tower : CatTower
func setup(dog_tower: DogTower):
	self.global_position = Vector2(1500, -1000)
	$Animation/bomb.global_position = dog_tower.global_position + Vector2(600, -250)
	$Animation/bomb_launch_up.global_position = dog_tower.global_position + Vector2(600, -250) + Vector2(0,121.5)
#	$Animation/bomb_launch_down/bomb.global_position = Vector2((dog_tower.global_position.x + cat_tower.global_position.x)/2,(dog_tower.global_position.y + cat_tower.global_position.y)/2)
	velocity = Vector2(0, 0)
	$Animation/bomb_launch_up.visible = false
	$Animation/bomb_launch_down/bomb.visible = false
#	launch()

func _physics_process(delta: float) -> void:
	if set_launch == 1:
		var collision = move_and_collide(velocity * delta)
	if set_launch == 2 :
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			var all_character = get_tree().get_nodes_in_group("characters")
			for charat in all_character:
				charat.kill()
			die()

func launch() :
	Data.store["nuclear_bomb"].amount -= 1
	velocity =  Vector2(0, -500)
	$Animation/bomb.visible = false
	$Animation/bomb_launch_up.visible = true
	$Animation/bomb_launch_down/bomb.visible = false
	set_launch = 1
	$AnimationPlayer.play("launch_up")
	await get_tree().create_timer(4, false).timeout
	$AnimationPlayer.play("launch_down")
	$Animation/bomb.visible = false
	$Animation/bomb_launch_up.visible = false
	$Animation/bomb_launch_down/bomb.visible = true
	velocity = Vector2(0, 500)
	set_launch = 2
	
func die():
	$Animation/bomb_launch_down/explosion_mushroom.visible = true
	$Animation/bomb_launch_down/bomb.visible = false
	$AnimationPlayer.play("explosion")
	await get_tree().create_timer(5.3, false).timeout
	queue_free()

func _on_control_bomb_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		launch()
