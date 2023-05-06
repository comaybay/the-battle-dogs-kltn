class_name Battlefield extends Node2D

var stage_width: int
var cat_tower_max_health: int

func _enter_tree() -> void:
	var file = FileAccess.open("res://resources/battlefield_data/doggonamu.json", FileAccess.READ)
	var battlefield_data = JSON.parse_string(file.get_as_text())
	file.close()

	## TODO: load battlefield map data
	var stage_width_margin: int = 300;
	stage_width = battlefield_data['stage_width'] + stage_width_margin * 2
	cat_tower_max_health = battlefield_data['cat_tower_health']
	
	var spawn_patterns = battlefield_data['spawn_patterns']
	var cats := load_cats(spawn_patterns) 
	for pattern in spawn_patterns:
		var timer = Timer.new()
		add_child(timer)
		timer.one_shot = false
		
		var delay_duration = float(pattern['delay'])
		var spawn_duration = float(pattern['duration'])
		
		var on_spawn_cat = func():
			var cat_scene: PackedScene = cats[pattern['name']]
			var cat = cat_scene.instantiate()
			cat.global_position = $CatTower.global_position - Vector2(100, 0)
			add_child(cat)
				
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

func _ready() -> void:
	var half_viewport_size = get_viewport().size / 2
	$Sky.position = Vector2(0, -$Sky.size.y)
	$Sky.size.x = stage_width
	
	$CatTower.position.x = stage_width - 500;
	$CatTower.position.y = -50
	$DogTower.position.x = 500
	$DogTower.position.y = -50
	
	$Land.position.x = stage_width / 2.0
	
	$Camera2D.position = Vector2(0, -half_viewport_size.y)
