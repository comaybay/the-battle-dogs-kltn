extends FSMState

const OFUDA_RED: DanmakuBulletKit = preload("res://scenes/danmaku/bullets/ofuda/ofuda_red.tres")
const OFUDA_GRAY: DanmakuBulletKit = preload("res://scenes/danmaku/bullets/ofuda/ofuda_gray.tres")
const YIN_YANG_ORB_SCENE: PackedScene = preload("res://scenes/characters/dogs/miko_dog/yin_yang_orb/yin_yang_orb.tscn")

@onready var miko_dog: MikoDog = owner

var battlefield: BaseBattlefield
var danmaku_space: DanmakuSpace
var attack_count: int = 0

var _twwen: Tween
var _original_position: Vector2

## some shitty code for determining if state has been interrupted (move to a different state)
var _current_frame: int
func _has_interupted(frame) -> bool: return frame != _current_frame

func _init() -> void:
	danmaku_space = InBattle.get_battlefield().get_danmaku_space()
		
# called when the state is activated
func enter(data: Dictionary) -> void:
	_current_frame = Engine.get_process_frames()
	
	var this_frame = _current_frame
	var fly_up_vector := Vector2(500  * miko_dog.move_direction, -1000)
	var fly_position = miko_dog.get_center_global_position() + fly_up_vector
	
	battlefield = InBattle.get_battlefield()
	miko_dog.n_AnimationPlayer.play("fly")
	
	var target_position: Vector2 = data['attack_point']
	var direction: Vector2 = (target_position - fly_position).normalized()
	$Patterns.rotation = direction.angle()
	
	_original_position = miko_dog.position
	_twwen = create_tween()
	
	_twwen.set_parallel(true)
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_IN_OUT)
	_twwen.tween_property(miko_dog, "position", fly_up_vector, 1).as_relative()
	
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_OUT)
	_twwen.tween_property(miko_dog, "rotation", deg_to_rad(15), 1)
	
	await _twwen.finished
	if _has_interupted(this_frame): return
	
	$ChargingUpSound.play()
	
	miko_dog.n_AnimationPlayer.play("pre_attack")
	miko_dog.n_AnimationPlayer.queue("attack")

	await get_tree().create_timer(1.1, false).timeout
	if _has_interupted(this_frame): return
	
	await _attack(direction, this_frame)
	if _has_interupted(this_frame): return
	
	_twwen = create_tween()
	_twwen.set_parallel(true)
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_IN_OUT)
	_twwen.tween_property(miko_dog, "position", _original_position, 1)
	
	_twwen.set_trans(Tween.TRANS_SINE)
	_twwen.set_ease(Tween.EASE_OUT)
	_twwen.tween_property(miko_dog, "rotation", 0, 0.5)
	
	miko_dog.n_AnimationPlayer.play_backwards("pre_attack")
	miko_dog.n_AnimationPlayer.queue("fly")
	
	await _twwen.finished
	if _has_interupted(this_frame): return
		
	miko_dog.n_AttackCooldownTimer.start()
	transition.emit("IdleState")
	
func _attack(direction: Vector2, this_frame: int) -> void:	
	var total_wait_time: int = 1
	var dog_level := (miko_dog as BaseDog).get_dog_level()
	var straight_bullets_num = 10 + dog_level
	const MAIN_PATTERN_SPEED: float = 2000
	
	if miko_dog.has_ability('yin_yang_orb'):
		_spawn_yin_yang_orb(dog_level, Vector2(300, 0))
	
	_pattern_straight_line(direction, MAIN_PATTERN_SPEED, straight_bullets_num, OFUDA_RED)
	
	if dog_level >= 2:
		_pattern_straight_line(
			direction.rotated(deg_to_rad(5)), MAIN_PATTERN_SPEED, straight_bullets_num, OFUDA_GRAY
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-5)), MAIN_PATTERN_SPEED, straight_bullets_num, OFUDA_GRAY
		)
		
	if dog_level >= 3:
		await Global.wait(0.25)
		if _has_interupted(this_frame): return
		
		_pattern_straight_line(
			direction.rotated(deg_to_rad(15)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, OFUDA_RED
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-15)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, OFUDA_RED
		)
		
	if dog_level >= 4:
		const SPEED: int = 1000
		const ROTATION: int = 20
		_pattern_straight_line(
			direction.rotated(deg_to_rad(10)), SPEED, straight_bullets_num, OFUDA_GRAY, -ROTATION
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-10)), SPEED, straight_bullets_num, OFUDA_GRAY, ROTATION
		)
		
	if miko_dog.has_ability('circular_ofudas'):
		var bullet_num: int = 4 * dog_level
		var loop: int = dog_level - 4
		const DURATION: float = 0.25
		const ROTATION: int = 10
		const SPEED: int = 1000
		_pattern_path(%Path1, DURATION, bullet_num, loop, ROTATION, SPEED, $OfudaSound1)
		_pattern_path(%Path2, DURATION, bullet_num, loop, -ROTATION, SPEED, $OfudaSound1)
		total_wait_time += DURATION * loop
	
	if dog_level >= 7 and miko_dog.has_ability('circular_ofudas'):
		var bullet_num: int = 25 + (25 * (dog_level - 7))
		var loop: int = dog_level - 7
		const DURATION: float = 0.5
		const ROTATION: float = 135
		const SPEED: int = 2000
		_pattern_path(%Path3, DURATION, bullet_num, loop, -ROTATION, SPEED, $OfudaSound3)
		_pattern_path(%Path4, DURATION, bullet_num, loop, ROTATION, SPEED, $OfudaSound3)
		total_wait_time += DURATION * loop
	
	var wait_timer := get_tree().create_timer(total_wait_time, false)
	await Global.wait(0.5)
	if _has_interupted(this_frame): return

	_pattern_straight_line(direction, MAIN_PATTERN_SPEED, straight_bullets_num, OFUDA_RED)
	
	_pattern_straight_line(
		direction.rotated(deg_to_rad(7.5)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, OFUDA_GRAY
	)
	_pattern_straight_line(
		direction.rotated(deg_to_rad(-7.5)), MAIN_PATTERN_SPEED, straight_bullets_num / 2, OFUDA_GRAY
	)
	
	if dog_level >= 3:
		_pattern_straight_line(
			direction.rotated(deg_to_rad(15)), MAIN_PATTERN_SPEED, straight_bullets_num / 3, OFUDA_RED
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-15)), MAIN_PATTERN_SPEED, straight_bullets_num / 3, OFUDA_RED
		)
	
	if dog_level >= 4:
		const ROTATION: int = 45
		const SPEED: int = 2500
		_pattern_straight_line(
			direction.rotated(deg_to_rad(20)), SPEED, straight_bullets_num, OFUDA_RED, -ROTATION
		)
		_pattern_straight_line(
			direction.rotated(deg_to_rad(-20)), SPEED, straight_bullets_num, OFUDA_RED, ROTATION
		)
	
	if wait_timer.time_left > 0:
		await wait_timer.timeout
		if _has_interupted(this_frame): return
	
	if miko_dog.has_ability('yin_yang_orb') and dog_level >= 9:
		Global.wait(0.25).connect(func():
			_spawn_yin_yang_orb(dog_level, Vector2(320, -800))
		)
		
func _spawn_yin_yang_orb(dog_level: int, velocity: Vector2) -> void:
	var yin_yang_orb: YinYangOrb = YIN_YANG_ORB_SCENE.instantiate()
	yin_yang_orb.setup(miko_dog.get_center_global_position(), dog_level, miko_dog.character_type, velocity)
	battlefield.add_child(yin_yang_orb)
		
func _pattern_straight_line(
	direction: Vector2, speed: float, bullet_num: int,
	ofuda_kit: DanmakuBulletKit, rotation: float = 0, back_accel: float = 0
) -> void:
	$OfudaSound2.play()
	var center_pos := miko_dog.get_center_global_position()
	var speed_reduction_unit: float = speed / (bullet_num * 1.5) 
	for i in range(bullet_num):
		var ofuda = danmaku_space.spawn(ofuda_kit, miko_dog.character_type)
		ofuda.start(func():
			ofuda.damage = miko_dog.ofuda_damage
			var ofuda_speed = speed - (i * speed_reduction_unit)
			var velocity: Vector2 = direction * ofuda_speed 
			ofuda.velocity = velocity
			ofuda.position = center_pos
			ofuda.rotation_speed = rotation
			ofuda.acceleration = velocity.normalized() * -back_accel
			await Global.wait(2.0)
			ofuda.rotation_speed = 0
		)

var _pattern_paths: Dictionary = {}
func _pattern_path(
	path: Path2D, duration: float, bullet_num: int, loop: int, rotation: float, speed: float, audio_player: AudioStreamPlayer
) -> void:
	var path_follow := path.get_node("PathFollow2D") as PathFollow2D
	path_follow.progress = 0.0
	var interval: float = 0 if bullet_num == 1 else duration / (bullet_num - 1)
	_pattern_paths[path] = {
		'path_follow': path_follow,
		'interval': interval,
		'sum_delta': interval,
		'sum_delta_sfx': 0,
		'progress_ration_unit': 1.0 / bullet_num,
		'loop': loop,
		'rotation': rotation,
		'speed': speed,
		'ofuda': OFUDA_GRAY,
		'audio_player': audio_player,
		'finished': false
	}

func update(delta) -> void:
	$Patterns.global_position = miko_dog.get_center_global_position()
	
	if _pattern_paths.is_empty():
		return
	
	for path in _pattern_paths:
		var _pattern_data := _pattern_paths[path] as Dictionary
		
		_pattern_data['sum_delta'] += delta
		_pattern_data['sum_delta_sfx'] += delta
		while _pattern_data['sum_delta'] >= _pattern_data['interval']:
			_pattern_data['sum_delta'] -= _pattern_data['interval']
			_spawn_bullet_on_path(_pattern_data)
			
			if _pattern_data['finished']:
				_pattern_paths.erase(path)
				break
			
			const SFX_INTERVAL = 0.09
			if _pattern_data['sum_delta_sfx'] >= SFX_INTERVAL:
				_pattern_data['sum_delta_sfx'] = 0
				_pattern_data['audio_player'].play()
	
func _spawn_bullet_on_path(_pattern_data: Dictionary) -> void:
	var path_follow := _pattern_data['path_follow'] as PathFollow2D
	var center_global_pos := miko_dog.get_center_global_position()
	var velocity = Vector2(1, 0) * _pattern_data['speed']
	var progress_unit: float = _pattern_data['progress_ration_unit'] 
	var current_loop = _pattern_data['loop']
	
	velocity = velocity.rotated((path_follow.global_position - center_global_pos).angle())
	
	var ofuda := danmaku_space.spawn(_pattern_data['ofuda'], miko_dog.character_type)
	ofuda.start( func():
		ofuda.damage = miko_dog.ofuda_damage
		ofuda.position = center_global_pos
		ofuda.velocity = velocity
		ofuda.rotation_speed = _pattern_data['rotation'] * sign(progress_unit)
		var passed_delta: float = _pattern_data['sum_delta']
		if not is_equal_approx(passed_delta, 0):
			ofuda.physic_process(passed_delta)
		await Global.wait(2.0 - passed_delta)
		ofuda.rotation_speed = 0
		
		if current_loop % 2: 
			ofuda.acceleration = -velocity
		
	)
	
	_pattern_data['ofuda'] = (
		OFUDA_RED if _pattern_data['ofuda'] == OFUDA_GRAY else OFUDA_GRAY
	)
	
	var dest_progress: float = 1.0 if progress_unit > 0 else 0.0
	if is_equal_approx(path_follow.progress_ratio, dest_progress):
		_pattern_data['progress_ration_unit'] = -progress_unit
		_pattern_data['loop'] -= 1
		if _pattern_data['loop'] == 0:
			_pattern_data['finished'] = true
	
	path_follow.progress_ratio += _pattern_data['progress_ration_unit'] 
		
func exit():
	_pattern_paths.clear()	
	_twwen.kill()
	miko_dog.rotation = 0
