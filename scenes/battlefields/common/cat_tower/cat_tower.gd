class_name CatTower extends StaticBody2D

signal zero_health
signal damage_taken
signal cat_spawn (cat: BaseCat)
signal boss_appeared

const EnergyExpand: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")
const BOSS_SHADER: ShaderMaterial = preload("res://shaders/outline_glow/outline_glow.material")
const MAX_RANDOM_DELAY: float = 2.5

var health: int
var max_health: int
var cats: Dictionary
var spawn_timers: Array[Timer]
var bosses_queue: Array
var cats_count: Dictionary

## number of bosses currently on battle
var alive_boss_count: int = 0

## position where effect for the tower should take place 
func get_effect_global_position() -> Vector2:
	return $EffectMarker.global_position

var _stage_data: Dictionary

func _enter_tree() -> void:
	_stage_data = InBattle.get_stage_data()
	var instant_spawns: Array = _stage_data.get('instant_spawns', [])
	var spawn_patterns: Array = _stage_data.get('spawn_patterns', [])
	var bosses: Array = _stage_data.get('bosses', [])
	
	var instant_spawn_cat_ids := instant_spawns.map(func(s): return s['id'])
	var spawn_cat_ids := spawn_patterns.map(func(s): return s['id'])
	var boss_cat_ids := bosses.map(func(s): return s['id'])
	var cat_ids := spawn_cat_ids + boss_cat_ids + instant_spawn_cat_ids
	cats = _load_cats(cat_ids) 
	
	for cat_id in cat_ids:
		cats_count[cat_id] = 0
	
	bosses.sort_custom(func(a, b):
		return a['health_at'] <= b['health_at']
	)
	bosses_queue = bosses

	for pattern in spawn_patterns:
		_setup_spawn_pattern(pattern)

	await InBattle.get_battlefield().ready
	_spawn_instate_spawn_cats(instant_spawns)

func _ready() -> void:
	max_health = _stage_data['cat_tower_health']
	health = max_health
	update_health_label()
			
func _load_cats(cat_ids: Array) -> Dictionary:
	var cats := {}
	for cat_id in cat_ids:
		if cats.has(cat_id):
			continue
			
		var is_dog: bool = (cat_id as String).ends_with('dog')
			
		if is_dog:
			cats[cat_id] = load("res://scenes/characters/dogs/%s/%s.tscn" % [cat_id, cat_id])
		else:
			cats[cat_id] = load("res://scenes/characters/cats/%s/%s.tscn" % [cat_id, cat_id])
			
	return cats

func _spawn_instate_spawn_cats(instant_spawns: Array) -> void:
	var battlefield = InBattle.get_battlefield() as BaseBattlefield
	for spawn_data in instant_spawns:	
		var cat_id: String = spawn_data['id']
		spawn(cat_id, spawn_data, func(cat: Character):
			if cat is AirUnitCat:
				cat.change_target_overtime = false
				var stage_rect := battlefield.get_stage_rect()
				cat.global_position.y = randf_range(-cat.movement_radius, stage_rect.position.y + cat.movement_radius)
			else:
				cat.global_position.y = 0
				cat.global_position.x = spawn_data.get('position', randf_range(battlefield.TOWER_MARGIN, battlefield.get_stage_width())) + 1000
		)

func _setup_spawn_pattern(pattern: Dictionary) -> void:
	var timer = Timer.new()
	spawn_timers.append(timer)
	add_child(timer)
	timer.one_shot = false
	
	var delay: float= pattern.get('delay', 0.0)
	var spawn_duration: float = pattern.get('interval', 5.0)
	var spawn_type: String = pattern.get('spawn_type', "default")		
	var limit: int = pattern.get('limit', -1)
	
	var spawn_cat := func():
		var cat_id: String = pattern['id']
		if limit < 0 or cats_count[cat_id] < limit:
			spawn(cat_id, pattern)
			
		timer.wait_time = spawn_duration + randf() * MAX_RANDOM_DELAY
	
	var start_timer: Callable
	var start_timer_no_delay: Callable
	
	if pattern.get('spawn_type') == 'once':
		timer.one_shot = true
		
		start_timer_no_delay = func():
			spawn_cat.call()
			timer.queue_free()
			spawn_timers.erase(timer)
	else:
		start_timer_no_delay = func():
			spawn_cat.call()
			timer.start()
			timer.timeout.connect(spawn_cat)
	
	if delay <= 0:
		start_timer = start_timer_no_delay
	else:
		start_timer = func():
			timer.start(delay)
			timer.timeout.connect(start_timer_no_delay, CONNECT_ONE_SHOT)

	if pattern.get('when') == 'boss_spawned':
		boss_appeared.connect(start_timer)
	else:
		start_timer.call_deferred()
	
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

func spawn(cat_id: String, data: Dictionary = {}, pre_ready_callback := Callable()) -> Character:
	var cat: Character = cats[cat_id].instantiate()
	
	if _stage_data.has('special_instruction'):
		cat.ready.connect(_apply_special_instruction.bind(cat))
		
	var spawn_pos: Vector2 = $SpawnMarker.global_position

	_set_cat_props(cat, data.get('props', {}))
	
	if cat is BaseCat:
		cat.setup(spawn_pos)
	elif cat is BaseDog:
		var dog_level: int = data.get('dog_level', 1)
		var dog_abilities: Array[String] = []
		dog_abilities.assign(data.get('dog_abilities', []))
		cat.setup(spawn_pos, dog_level, dog_abilities)
	
	if pre_ready_callback.is_valid():
		pre_ready_callback.call(cat)
	
	InBattle.get_battlefield().add_child(cat)
	
	cat_spawn.emit(cat)
	
	cats_count[cat_id] += 1
	cat.tree_exiting.connect(func(): cats_count[cat_id] -= 1)
	return cat
	
func spawn_boss(data: Dictionary) -> void:
	boss_appeared.emit()
	
	var cat: Character = cats[data['id']].instantiate()

	var spawn_pos: Vector2 = $SpawnMarker.global_position
	if cat is BaseCat:
		cat.setup(spawn_pos, true) 
	elif cat is BaseDog:
		var dog_level: int = data.get('dog_level', 1)
		var dog_abilities: Array[String] = []
		dog_abilities.assign(data.get('dog_abilities', []))
		cat.setup(spawn_pos, dog_level, dog_abilities, true)
		
	cat.ready.connect(
		func(): 
			if data.get('effect') != 'none':
				_add_boss_shader(cat)
	, CONNECT_ONE_SHOT)
	
	_set_cat_props(cat, data.get('props', {}))
	_set_cat_buffs(cat, data.get('buffs', []))
	
	InBattle.get_battlefield().add_child(cat)
	alive_boss_count += 1
	cat.tree_exited.connect(func(): alive_boss_count -= 1)
	
	knockback_dogs()

func _set_cat_props(cat: Character, props: Dictionary) -> void:
	for prop_name in props:
		var prop_val = cat.get(prop_name) 
		if prop_val != null:
			var prop_new_value = props[prop_name].get("value")
			if prop_new_value != null:
				cat.set(prop_name, prop_new_value)
			
			var prop_scale = props[prop_name].get("scale")
			if prop_scale != null:
				cat.set(prop_name, cat.get(prop_name) * prop_scale)

## deprecated feature, use props instead 
func _set_cat_buffs(cat: Character, buffs: Array) -> void:
	for buff in buffs:
		var prop_name = buff["name"]
		var prop_val = cat.get(prop_name) 
		if prop_val != null:
			var prop_new_value = buff.get("value")
			if prop_new_value:
				cat.set(prop_name, prop_new_value)
			
			var prop_scale = buff.get("scale")
			if prop_scale:
				cat.set(prop_name, cat.get(prop_name) * prop_scale)

func _add_boss_shader(cat: Character) -> void:
	var shader = BOSS_SHADER.duplicate()
	shader.set_shader_parameter("frame_size", cat.n_Sprite2D.get_rect().size)
	cat.n_Sprite2D.material = shader
	cat.n_Sprite2D.frame_changed.connect(func():
		shader.set_shader_parameter("frame_coords", cat.n_Sprite2D.frame_coords)
	) 

func _apply_special_instruction(cat: Character):
	if _stage_data['special_instruction'] == "invert_color":
		cat.n_Sprite2D.material = load("res://shaders/invert_color/invert_color.material")

func knockback_dogs(knockback_scale: float = 2.5) -> void:
	var effect_space: Node2D = get_tree().current_scene.get_node("EffectSpace")
	var effect := EnergyExpand.instantiate()
	
	effect.setup(get_effect_global_position(), "on_emitter")
	InBattle.get_battlefield().get_effect_space().add_child(effect)
	
	for dog in get_tree().get_nodes_in_group("dogs"):
		dog.knockback(knockback_scale)
