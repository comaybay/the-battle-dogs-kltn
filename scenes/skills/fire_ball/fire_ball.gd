extends Node2D

const FireBall =  preload("res://scenes/skills/fire_ball/ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var posti = InBattle.STAGE_WIDTH_MARGIN 
	for i in range(0,7):
		var item = FireBall.instantiate()
		randomize()	 
		var random_value = randi_range(posti-100 , InBattle.battlefield_data["stage_width"] - posti - 1100)
		var random_value_y = randi_range(-800,-900)
		item.global_position = Vector2(random_value, random_value_y) 		
		self.add_child(item)
		await get_tree().create_timer(1).timeout
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
