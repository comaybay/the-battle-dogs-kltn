@tool
class_name DanmakuSpace extends BulletsEnvironment

const DANMAKU_OUTER_MARGIN: int = 1000
const MAX_POOL_SIZE = 7000

var _debug_label: Label = null

func _init() -> void:
	super._init()
	tree_entering.connect(_config_danmaku_space)
	
	if not Engine.is_editor_hint() and Debug.is_debug_mode():
		var canvas := CanvasLayer.new()
		canvas.layer = 9
		_debug_label = Label.new()
		_debug_label.position = Vector2(180, 180)
		_debug_label.add_theme_font_size_override("font_size", 20)
		_debug_label.add_theme_color_override("font_outline_color", Color.DARK_GREEN)
		_debug_label.add_theme_constant_override("outline_size", 6)
		canvas.add_child(_debug_label)
		add_child(canvas)
		set_process(true)
	else:
		set_process(false)
		
func _config_danmaku_space(_node: BulletsEnvironment) -> void:
	var battlefield := InBattle.get_battlefield() as BaseBattlefield
	
	var ids: Array[String] = []
	ids.append_array(battlefield.get_player_data().team_dog_ids.filter(func(id): return id != null))
	
	var pool_sizes := _get_dogs_bullet_pool_sizes(ids)
	_add_cats_bullet_pool_sizes(pool_sizes)
	
	_setup_bullets(pool_sizes)
	
func _add_cats_bullet_pool_sizes(pool_sizes: Dictionary) -> void:
	var battlefield := InBattle.get_battlefield() as BaseBattlefield
	var data: Dictionary = battlefield.get_battlefield_data()
	var enemy_bullets_arr: Array[Dictionary] = []
	enemy_bullets_arr.append_array(data["spawn_patterns"].filter(
		func(pattern): 
			var id: String = pattern['id']
			return id.ends_with("dog") and Data.dog_info[id].has("danmaku_bullets")
	))

	enemy_bullets_arr.append_array(data.get("bosses", []).filter(
		func(pattern): 
			var id: String = pattern['id']
			return id.ends_with("dog") and Data.dog_info[id].has("danmaku_bullets")
	))
	
	enemy_bullets_arr.assign(enemy_bullets_arr.map(
		func(pattern): return Data.dog_info[pattern['id']]["danmaku_bullets"]
	)) 
		
	for enemy_bullets in enemy_bullets_arr:
		for bullet_id in enemy_bullets:
			pool_sizes[bullet_id] = pool_sizes.get(bullet_id, 0) + enemy_bullets[bullet_id]
			
func _setup_bullets(pool_sizes: Dictionary):
	for bullet_id in pool_sizes:
		var parts := (bullet_id as String).split(":")
		var bullet = load("res://scenes/danmaku/bullets/%s/%s_%s.tres" % [parts[0], parts[0], parts[1]]) 
		register_bullet(bullet, pool_sizes[bullet_id])
	
func _get_dogs_bullet_pool_sizes(dog_ids: Array[String]) -> Dictionary:
	var danmaku_dog_ids = dog_ids.filter(
		func(id): return Data.dog_info[id].has('danmaku_bullets')
	)
	
	var pool_sizes := {}
	for dog_id in danmaku_dog_ids:
		var bullet_pool_sizes = Data.dog_info[dog_id]['danmaku_bullets']
		## abitrary numbers here if spawn_limit is not set
		var spawn_limit = Data.dog_info[dog_id].get('spawn_limit', 3)
		
		for bullet_id in bullet_pool_sizes:
			pool_sizes[bullet_id] = pool_sizes.get(bullet_id, 0) + bullet_pool_sizes[bullet_id] * spawn_limit

	return pool_sizes

## register bullet so that they can be used in battle
func register_bullet(bullet: DanmakuBulletKit, pool_size: int = 3000) -> void:
	assert(not bullet_kits.has(bullet), "ERROR: bullet is already registered.")
		
	ready.connect(func():
		var stage_rect := InBattle.get_battlefield().get_stage_rect()
		stage_rect.position -= Vector2(DANMAKU_OUTER_MARGIN, DANMAKU_OUTER_MARGIN)
		stage_rect.size += Vector2(DANMAKU_OUTER_MARGIN * 2, DANMAKU_OUTER_MARGIN * 2)

		bullet.active_rect = stage_rect
		bullet.collision_layer = 0b1000,
		CONNECT_ONE_SHOT
	)
	
	var index: int = _get("bullet_types_amount") 
	_set("bullet_types_amount", index + 1)
	
	bullet_kits[index] = bullet
	pools_sizes[index] = min(pool_size, MAX_POOL_SIZE) 
	z_indices[index] = 50

## spawn bullet, returns the bullet controller, remember to check if bullet spawned successfully using the controller
func spawn(bullet: DanmakuBulletKit, character_type: Character.Type) -> DanmakuBulletController:
	var id = Bullets.obtain_bullet(bullet)
	var controller := DanmakuBulletController.new()
	controller.setup(bullet, id, character_type)
	return controller
	
func has_bullet(bullet: DanmakuBulletKit) -> bool:
	return bullet_kits.has(bullet)

func get_pool_size(bullet: DanmakuBulletKit) -> int:
	return Bullets.get_pool_size(bullet)
	
## increase or decrease pool size of bullet, result value will always be >= 1
func adjust_pool_size(bullet: DanmakuBulletKit, size: int) -> void:
	var index := pools_sizes.find(bullet)
	pools_sizes[index] = max(1, Bullets.get_pool_size(bullet) + size)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_debug_label.text = ""
	
	if not Debug.is_draw_debug():
		return
	
	_debug_label.text = "shared_timers: %s\n" % Global._shared_timers.size()
	
	_debug_label.text += "Total bullets %s/%s\n" % [
		Bullets.get_total_active_bullets(), Bullets.get_total_available_bullets()
	] 
	
	for kit in bullet_kits:
		_debug_label.text += "%s: %s/%s\n" % [
			kit.resource_path.get_file(), 
			Bullets.get_active_bullets(kit),
			Bullets.get_available_bullets(kit)
	]
