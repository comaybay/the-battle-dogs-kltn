class_name CatTower extends StaticBody2D

signal zero_health
signal damage_taken
signal cat_spawn (cat: BaseCat)
signal boss_appeared

const EnergyExpand: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")
const boss_shader: ShaderMaterial = preload("res://shaders/outline_glow/outline_glow.material")
const MAX_RANDOM_DELAY: float = 2.5

var health: int
var max_health: int
var cats: Dictionary
var spawn_timers: Array[Timer]
var bosses_queue: Array
# number of bosses currently on battle
var alive_boss_count: int = 0

## position where effect for the tower should take place 
var effect_global_position: Vector2:
	get: return $Marker2D.global_position

var _battlefield_data: Dictionary


func _ready() -> void:
	var battlefield := get_tree().current_scene as Battlefield
	_battlefield_data = battlefield.get_battlefield_data()
	
	$Sprite2D.texture = load("res://resources/battlefield_themes/%s/cat_tower.png" % battlefield.get_theme())
	max_health = _battlefield_data['cat_tower_health']
	health = max_health
	update_health_label()
	
	var spawn_patterns: Array = _battlefield_data['spawn_patterns']
	var bosses: Array = _battlefield_data['bosses'] if _battlefield_data.has('bosses') else []
	
	var spawn_cat_names := spawn_patterns.map(func(s): return s['name'])
	var boss_cat_names := bosses.map(func(s): return s['name'])
	var cat_names := spawn_cat_names + boss_cat_names 
	cats = load_cats(cat_names) 
	
	bosses.sort_custom(func(a, b):
		return a['health_at'] <= b['health_at']
	)
	bosses_queue = bosses
	
	for pattern in spawn_patterns:
		var timer = Timer.new()
		spawn_timers.append(timer)
		add_child(timer)
		timer.one_shot = false
		
		var delay_duration = float(pattern['delay'])
		var spawn_duration = float(pattern['duration'])
		
		var on_spawn_cat = func():
			spawn(pattern['name'])
			timer.wait_time = spawn_duration + randf() * MAX_RANDOM_DELAY
				
		if delay_duration <= 0:
			timer.start(spawn_duration + randf() * MAX_RANDOM_DELAY)
			timer.timeout.connect(on_spawn_cat)
		else:
			timer.start(delay_duration)
			
			var on_timeout_delay = func():
				timer.start(spawn_duration + randf() * MAX_RANDOM_DELAY)
				timer.timeout.connect(on_spawn_cat)
			
			timer.timeout.connect(on_timeout_delay, CONNECT_ONE_SHOT)
			
func load_cats(cat_names: Array) -> Dictionary:
	var cats := {}
	for cat_name in cat_names:
		if not cats.has(cat_name):
			cats[cat_name] = load("res://scenes/characters/cats/%s/%s.tscn" % [cat_name, cat_name])
			
	return cats

func update_health_label():
	$HealthLabel.text = "%s/%s HP" % [health, max_health]

func take_damage(damage: int) -> void:
	if health <= 0:
		return	
	
	# only take full damage if no bosses are on battle
	if alive_boss_count > 0:
		health = max(health - 1, 1) 
	elif bosses_queue.size() > 0:
		health = max(health - damage, 1) 
	else:	
		health = max(health - damage, 0) 
	
	damage_taken.emit()
	$AnimationPlayer.play("shake" if health > 0 else "fall")
	
	while bosses_queue.size() > 0:
		var boss_info = bosses_queue.back()
		if health <= boss_info['health_at']:
			health = boss_info['health_at']
			spawn_boss(boss_info)
			bosses_queue.pop_back()
		else: 
			break
	
	update_health_label()
	
	if health <= 0:
		for cat in get_tree().get_nodes_in_group("cats"):
			cat.kill()
	
		for timer in spawn_timers:
			timer.queue_free()			
			
		zero_health.emit()

func spawn(cat_name: String) -> BaseCat:
	var cat: BaseCat = cats[cat_name].instantiate()
	cat.ready.connect(_apply_special_instruction.bind(cat))
	
	get_tree().current_scene.add_child(cat)
	var offset_y = cat.global_position.y - cat.get_bottom_global_position().y
	cat.setup(global_position + Vector2(-100, offset_y))
	
	cat_spawn.emit(cat)
	return cat
	
func spawn_boss(boss_info: Dictionary) -> void:
	boss_appeared.emit()
	
	var cat: BaseCat = cats[boss_info['name']].instantiate()
	cat.is_boss = true
	cat.global_position = global_position - Vector2(100, 0)
	cat.ready.connect(
		func(): 
			_apply_special_instruction(cat)
			if cat.allow_boss_effect == true:
				var shader = boss_shader.duplicate()
				shader.set_shader_parameter("frame_size", cat.n_Sprite2D.get_rect().size)
				cat.n_Sprite2D.material = shader
				cat.n_Sprite2D.frame_changed.connect(func():
					shader.set_shader_parameter("frame_coords", cat.n_Sprite2D.frame_coords)
				), CONNECT_ONE_SHOT) 
	
	for buff in boss_info['buffs']:
		var prop_name = buff["name"]
		var prop_val = cat.get(prop_name) 
		if prop_val != null:
			var prop_new_value = buff.get("value")
			if prop_new_value:
				cat.set(prop_name, prop_new_value)
			
			var prop_scale = buff.get("scale")
			if prop_scale:
				cat.set(prop_name, cat.get(prop_name) * prop_scale)
	
	var tree := get_tree()
		
	tree.current_scene.add_child(cat)
	alive_boss_count += 1
	cat.tree_exited.connect(func(): alive_boss_count -= 1)
	
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	
	var effect := EnergyExpand.instantiate()
	effect.setup(effect_global_position, "on_emitter")
	tree.current_scene.get_node("EffectSpace").add_child(effect)
	
	for dog in tree.get_nodes_in_group("dogs"):
		dog.knockback(2.5)

func _apply_special_instruction(cat: BaseCat):
	if _battlefield_data.has('special_instruction') and _battlefield_data['special_instruction'] == "invert_color":
		cat.n_Sprite2D.material = load("res://shaders/invert_color/invert_color.material")
