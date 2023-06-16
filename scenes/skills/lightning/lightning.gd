extends Node2D

const FireBall =  preload("res://scenes/skills/lightning/light.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var posti = InBattle.STAGE_WIDTH_MARGIN 
	var count = int((InBattle.battlefield_data["stage_width"]- 1400) / 350)
	for i in range(count+1):
		var item = FireBall.instantiate()
		#randi_range(posti-100 , InBattle.battlefield_data["stage_width"] - posti - 1100)
		var random_value = i * 350 + posti + 450
		var random_value_y = randi_range(-800,-900)
		item.global_position = Vector2(random_value, random_value_y) 		
		self.add_child(item)
		$AudioStreamPlayer2D.play()
		await get_tree().create_timer(0.2).timeout
		
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
