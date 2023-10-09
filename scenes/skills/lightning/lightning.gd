extends Node2D

const FireBall =  preload("res://scenes/skills/lightning/light.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var battlefield := get_tree().current_scene as BaseBattlefield
	var posti = 300
	var count = int((battlefield.get_stage_width() - 1400) / 350)
	for i in range(count+1):
		var item = FireBall.instantiate()
		var random_value = i * 350 + posti + 450
		var random_value_y = randi_range(-800,-900)
		item.global_position = Vector2(random_value, random_value_y) 		
		self.add_child(item)
		await get_tree().create_timer(0.2, false).timeout
	
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
