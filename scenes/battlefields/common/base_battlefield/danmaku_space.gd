@tool
class_name DanmakuSpace extends BulletsEnvironment

const DANMAKU_OUTER_MARGIN: int = 10000

signal physics_processing(delta: float)

var _debug_label: Label = null

func _init() -> void:
	super._init()
	tree_entering.connect(_config_danmaku_space)
	
	if not Engine.is_editor_hint() and Debug.is_debug_mode():
		var canvas := CanvasLayer.new()
		canvas.layer = 9
		_debug_label = Label.new()
		_debug_label.position = Vector2(200, 200)
		_debug_label.add_theme_color_override("font_color", Color.DARK_OLIVE_GREEN)
		_debug_label.add_theme_font_size_override("font_size", 24)
		canvas.add_child(_debug_label)
		add_child(canvas)
		set_process(true)
	else:
		set_process(false)
		
func _config_danmaku_space(_node: BulletsEnvironment) -> void:
	var battlefield := InBattle.get_battlefield() as BaseBattlefield
	
	var ids: Array[String] = []
	ids.append_array(battlefield.get_player_data().team_dog_ids.filter(func(id): return id != null))
	
	if battlefield is Battlefield:
		var data: Dictionary = battlefield.get_battlefield_data()
		ids.append_array(data["spawn_patterns"].filter(
			func(pattern): return pattern['id'].ends_with("dog")
		).map(
			func(pattern): return pattern['id']
		))
		
		ids.append_array(data["bosses"].filter(
			func(pattern): return pattern['id'].ends_with("dog")
		).map(
			func(pattern): return pattern['id']
		))
	
	var setup_data := _get_bullet_setup_data(ids)
	_setup_bullets(setup_data)

func _setup_bullets(setup_data: Dictionary):
	for bullet_id in setup_data:
		var parts := (bullet_id as String).split(":")
		var bullet = load("res://scenes/danmaku/bullets/%s/%s_%s.tres" % [parts[0], parts[0], parts[1]]) 
		register_bullet(bullet, setup_data[bullet_id])
	
func _get_bullet_setup_data(dog_ids: Array[String]) -> Dictionary:
	var bullets_data = dog_ids.filter(
		func(id): return Data.dog_info[id].has('danmaku_bullets')
	).map(
		func(id): return Data.dog_info[id]['danmaku_bullets']
	)
	
	var setup_data := {}
	for bullet_data in bullets_data:
		for bullet_id in bullet_data:
			if setup_data.has(bullet_id):
				setup_data[bullet_id] += bullet_data[bullet_id] 
			else: 
				setup_data[bullet_id] = bullet_data[bullet_id]
	return setup_data

## register bullet so that they can be used in battle
func register_bullet(bullet: DanmakuBulletKit, pool_size: int = 3000) -> void:
	assert(not bullet_kits.has(bullet), "ERROR: bullet is already registered.")
		
	ready.connect(func():
		var stage_rect := InBattle.get_battlefield().get_stage_rect()
		stage_rect.position -= Vector2(DANMAKU_OUTER_MARGIN, DANMAKU_OUTER_MARGIN)
		stage_rect.size += Vector2(DANMAKU_OUTER_MARGIN * 2, DANMAKU_OUTER_MARGIN * 2)

		bullet.use_viewport_as_active_rect = false
		bullet.active_rect = stage_rect
		bullet.collision_layer = 0b1000,
		CONNECT_ONE_SHOT
	)
	
	var index: int = _get("bullet_types_amount") 
	_set("bullet_types_amount", index + 1)
	
	bullet_kits[index] = bullet
	pools_sizes[index] = pool_size
	z_indices[index] = 50

## spawn bullet, returns the bullet controller, remember to check if bullet spawned successfully using the controller
func spawn(bullet: DanmakuBulletKit, character_type: Character.Type) -> DanmakuBulletController:
	var id = Bullets.obtain_bullet(bullet)
	var controller := DanmakuBulletController.new()
	controller.setup(bullet, id, character_type, self)
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
	
	for kit in bullet_kits:
		_debug_label.text += "%s: %s\n" % [kit.resource_path.get_file(), Bullets.get_active_bullets(kit)]

func _physics_process(delta: float) -> void:
	physics_processing.emit(delta)
