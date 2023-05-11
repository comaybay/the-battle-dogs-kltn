extends StaticBody2D

var health: int
var max_health: int
var spawn_timers: Array[Timer]

func _ready() -> void:
	max_health = InBattle.battlefield_data['cat_tower_health']
	health = max_health
	update_health_label()
	
	var spawn_patterns = InBattle.battlefield_data['spawn_patterns']
	var cats := load_cats(spawn_patterns) 
	for pattern in spawn_patterns:
		var timer = Timer.new()
		spawn_timers.append(timer)
		add_child(timer)
		timer.one_shot = false
		
		var delay_duration = float(pattern['delay'])
		var spawn_duration = float(pattern['duration'])
		
		var on_spawn_cat = func():
			var cat_scene: PackedScene = cats[pattern['name']]
			spawn(cat_scene)
				
		if delay_duration <= 0:
			timer.start(spawn_duration)
			timer.timeout.connect(on_spawn_cat)
		else:
			timer.start(delay_duration)
			
			var on_timeout_delay = func():
				timer.start(spawn_duration)
				timer.timeout.connect(on_spawn_cat)
			
			timer.timeout.connect(on_timeout_delay, CONNECT_ONE_SHOT)

func load_cats(spawn_patterns: Variant) -> Dictionary:
	var cats := {}
	for pattern in spawn_patterns:
		var cat_name = pattern['name']
		if not cats.has(cat_name):
			cats[cat_name] = load("res://scenes/characters/cats/%s/%s.tscn" % [cat_name, cat_name])
			
	return cats

func update_health_label():
	$HealthLabel.text = "%s/%s" % [health, max_health]

func take_damage(damage: int) -> void:
	if health <= 0:
		return	
	
	health = max(health - damage, 0) 
	update_health_label()
	$AnimationPlayer.play("shake" if health > 0 else "fall")
	
	if health <= 0:
		for cat in get_tree().get_nodes_in_group("cats"):
			cat.kill()
	
		for timer in spawn_timers:
			timer.queue_free()			

func spawn(cat_scene: PackedScene) -> void:
	var cat = cat_scene.instantiate()
	cat.global_position = global_position - Vector2(100, 0)
	get_tree().current_scene.add_child(cat)
