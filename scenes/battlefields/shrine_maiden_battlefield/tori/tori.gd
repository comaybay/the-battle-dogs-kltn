class_name Tori extends StaticBody2D

const EnergyExpand: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")

const BULLET_GRAY: DanmakuBulletKit = preload("res://scenes/danmaku/bullets/bullet1/bullet1_gray.tres")
const BULLET_RED: DanmakuBulletKit = preload("res://scenes/danmaku/bullets/bullet1/bullet1_red.tres")
const BULLET_BLUE: DanmakuBulletKit = preload("res://scenes/danmaku/bullets/bullet1/bullet1_blue.tres")
const BULLET_GREEN: DanmakuBulletKit = preload("res://scenes/danmaku/bullets/bullet1/bullet1_green.tres")

const BULLET_KITS: Array[DanmakuBulletKit] = [BULLET_GRAY, BULLET_RED, BULLET_BLUE, BULLET_GREEN]

signal zero_health

var danmaku_space: DanmakuSpace
var health: int
var max_health: int
var growl_num: int
var next_growl_health: int

func get_effect_global_position() -> Vector2:
	return $Marker2D.global_position
	
func _enter_tree() -> void:
	danmaku_space = InBattle.get_danmaku_space()
	for bullet_kit in BULLET_KITS:
		danmaku_space.register_bullet(bullet_kit, 100)
	
func setup(position_x: float, health: int, growl_num: int) -> void:
	position.x = BaseBattlefield.TOWER_MARGIN + position_x
	self.health = health
	max_health = health
	update_health_label()
	self.growl_num = growl_num
	next_growl_health = max_health - roundi(max_health / (growl_num + 1))
	
	await Global.wait(1)
	attack()
func take_damage(damage: int) -> void:
	if health <= 0:
		return
	
	if not InBattle.in_request_mode:
		health = max(health - damage, 0) 
	
	if health > 0:
		if next_growl_health != 0 and health <= next_growl_health:
			next_growl_health -= roundi(max_health / (growl_num + 1))
			$AnimationPlayer.play("growl")
			$AnimationPlayer.queue("RESET")
			attack()
		else:	
			$AnimationPlayer.play("shake")
	else:
		$AnimationPlayer.play("destroy")
		zero_health.emit()
		collision_layer = 0
		$HealthLabel.visible = false

	update_health_label()

func update_health_label() -> void:
	$HealthLabel.text = "%s/%s HP" % [health, max_health]

func attack() -> void:
	var effect: FXEnergyExpand = EnergyExpand.instantiate()
	effect.setup($FaceMarker.global_position, "on_emitter")
	InBattle.get_battlefield().get_effect_space().add_child(effect)
	
	for dog in get_tree().get_nodes_in_group("dogs"):
		dog.knockback(1.5)

	for i in range(4):
		var pattern := Danmaku.pattern_cirle($FaceMarker.global_position, 100) as DanmakuPatternCircle
		pattern.step = deg_to_rad(10)
		pattern.angle_offset = deg_to_rad(-45 + i * 90)
		pattern.clockwise_direction = i % 2 == 0
		pattern.tween(1, 0, _on_pattern_callback)
		pattern.finished.connect(pattern.queue_free)
		
	for i in range(4):
		var pattern := Danmaku.pattern_cirle($FaceMarker.global_position, 400) as DanmakuPatternCircle
		pattern.step = deg_to_rad(10)
		pattern.angle_offset = deg_to_rad(-90 + i * 90)
		pattern.clockwise_direction = i % 2 == 0
		pattern.tween(1, 0, _on_pattern_callback)
		pattern.finished.connect(pattern.queue_free)
	
func _on_pattern_callback(position: Vector2, angle: float, passed_delta: float, index: int) -> void:
	var bullet := danmaku_space.spawn(BULLET_KITS.pick_random(), Character.Type.CAT)
	bullet.damage *= (InBattle.get_battlefield() as Battlefield).get_cat_power_scale()
	bullet.position = position
	bullet.rotation = angle
	bullet.velocity = Vector2(900 - 20 * index, 0).rotated(angle)
	bullet.rotation_speed = deg_to_rad(100 * (2 * int(index % 2) - 1))
	bullet.physic_process(passed_delta);
	
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(bullet, "velocity_scale", 0.0, 2.0)
	await tween.finished
	
	if bullet.is_destroyed(): return
	
	bullet.rotation_speed = 0
	var new_velocity: Vector2
	var dogs := get_tree().get_nodes_in_group("dogs")
	if dogs.is_empty():
		new_velocity = Vector2(bullet.velocity.length(), 0).rotated(deg_to_rad(90 + 45))
	else:
		var dog := dogs.pick_random() as BaseDog
		new_velocity = Vector2(bullet.velocity.length(), 0).rotated((dog.global_position - bullet.position).angle())
			
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bullet, "rotation", new_velocity.angle(), 1.0).from(bullet.velocity.angle() + deg_to_rad(5.0))
	
	tween.tween_property(bullet, "velocity_scale", 1.0, 2.0)
	tween.parallel().tween_property(bullet, "rotation_speed", deg_to_rad(-5.0), 2.0)

	bullet.velocity = new_velocity * randf_range(5.0, 10.0)
	
