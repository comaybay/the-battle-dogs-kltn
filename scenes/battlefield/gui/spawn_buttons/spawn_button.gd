class_name SpawnButton extends Button

var dog_id: String
var spawn_price: int
var spawn_type: String
var spawn_time: float
var spawn_input_action: String

var is_active: bool
var _dog_tower: BaseDogTower
var _player_data: BaseBattlefieldPlayerData
var _spawn_dog: BaseDog

func is_spawn_ready() -> bool:
	return $SpawnTimer.is_stopped()

func can_afford_dog():
	return _player_data.get_money_int() >= spawn_price

func can_spawn():
	var result := can_afford_dog() and is_spawn_ready() and is_active
	
	if spawn_type == 'once':
		result = result and _spawn_dog == null
		
	return result

func setup(dog_id: String, input_action: String, is_active: bool, dog_tower: BaseDogTower, player_data: BaseBattlefieldPlayerData) -> void:
	self.dog_id = dog_id 
	set_active(is_active)
	_dog_tower = dog_tower
	_player_data = player_data
	spawn_input_action = input_action
	spawn_type = Data.dog_info[dog_id]['spawn_type'] 	
		
	$Icon.texture = load("res://resources/icons/%s_icon.png" % dog_id)

	spawn_time = Data.dog_info[dog_id]['spawn_time']
	if spawn_time > 0:
		$SpawnTimer.wait_time = Data.dog_info[dog_id]['spawn_time']
	
	$SpawnTimer.timeout.connect(_on_spawn_ready)
	
	spawn_price = Data.dog_info[dog_id]['spawn_price']
	$MoneyLabel.text = str(spawn_price) + "₵"
	pressed.connect(_on_spawn_pressed)
	$AnimationPlayer.play("ready")
	set_process(true)
	set_process_input(true)
	
func set_active(active: bool) -> void:
	is_active = active
	$MoneyLabel.visible = active
	self.disabled = !active
	
func _ready() -> void:
	$MoneyLabel.text = ""
	$Background.frame = 1
	$MoneyLabel.visible = false
	$ProgressBar.visible = false
	$AnimationPlayer.play("empty")
	set_process(false)
	set_process_input(false)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(spawn_input_action) and can_spawn():
		spawn_dog()
			
func _on_spawn_pressed() -> void:
	spawn_dog()
	
func spawn_dog() -> BaseDog:

	_player_data.fmoney -= spawn_price
	_spawn_dog = _dog_tower.spawn(dog_id)

	_start_recharge_ui()
	
	return _spawn_dog

func _start_recharge_ui() -> void:
	self.disabled = true
	$ProgressBar.visible = true
	$Background.frame = 1
	$SpawnTimer.start()
	
func _on_spawn_ready() -> void:
	$ProgressBar.visible = false
	self.disabled = not can_spawn()
	$Background.frame = 0 if can_spawn() else 1	

func _process(delta: float) -> void:
	if $ProgressBar.visible:
		var elapsed_time = spawn_time - $SpawnTimer.time_left	
		
		var tween = create_tween()
		var value = tween.interpolate_value(
			0.0, 100.0, elapsed_time, spawn_time, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		$ProgressBar.value = value
		tween.kill()
	
	self.disabled = not can_spawn()
	$Background.frame = 0 if can_spawn() else 1	
