class_name SpawnButton extends Button

var dog_tower
var dog_scene: PackedScene
var is_active: bool

var spawn_price: int
var spawn_type: String
var spawn_input_action: String

var _spawn_dog: BaseDog

func is_spawn_ready() -> bool:
	return $SpawnTimer.is_stopped()

func can_afford_dog():
	return InBattle.money >= spawn_price

func can_spawn():
	var result := can_afford_dog() and is_spawn_ready() and is_active
	
	if spawn_type == 'once':
		result = result and _spawn_dog == null
		
	return result

func setup(name_id: String, input_action: String, is_active: bool) -> void:
	set_active(is_active)
	spawn_input_action = input_action
	spawn_type = Data.dog_info[name_id]['spawn_type'] 	
		
	$Icon.texture = load("res://resources/icons/%s_icon.png" % name_id)
	dog_scene = load("res://scenes/characters/dogs/%s/%s.tscn" % [name_id, name_id])

	var spawn_time: float = Data.dog_info[name_id]['spawn_time']
	if spawn_time > 0:
		$SpawnTimer.wait_time = Data.dog_info[name_id]['spawn_time']
	
	$SpawnTimer.timeout.connect(_on_spawn_ready)
	
	spawn_price = Data.dog_info[name_id]['spawn_price']
	$MoneyLabel.text = str(spawn_price) + "₵"
	pressed.connect(_on_pressed)
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
	dog_tower = get_tree().current_scene.get_dog_tower()
	set_process(false)
	set_process_input(false)

func _on_spawn_ready() -> void:
	$ProgressBar.visible = false
	
func _process(delta: float) -> void:
	self.disabled = !can_spawn()
	$Background.frame = 0 if can_spawn() else 1	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(spawn_input_action) and can_spawn():
		spawn_dog()
			
func _on_pressed() -> void:
	spawn_dog()
	
func spawn_dog() -> BaseDog:
	self.disabled = true

	InBattle.money -= spawn_price
	_spawn_dog = dog_tower.spawn(dog_scene)

	$ProgressBar.visible = true
	$Background.frame = 1
	var tween := create_tween()
	tween.tween_method(_tween_progress, 0, 100, $SpawnTimer.wait_time);
	$SpawnTimer.start()
	
	return _spawn_dog

func _tween_progress(value: float) -> void:
	$ProgressBar.value = value
