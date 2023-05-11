extends Button

var dog_tower: DogTower
var dog_scene: PackedScene
var is_active: bool

var spawn_price: int

func setup(name_id: String, is_active: bool) -> void:
	set_active(is_active)
	$Icon.texture = load("res://resources/icons/%s_icon.png" % name_id)
	dog_scene = load("res://scenes/characters/dogs/%s/%s.tscn" % [name_id, name_id])
	$SpawnTimer.wait_time = Data.dog_info[name_id]['spawn_time']
	$SpawnTimer.timeout.connect(_on_spawn_ready)
	
	spawn_price = Data.dog_info[name_id]['spawn_price']
	$MoneyLabel.text = str(spawn_price) + "₵"
	pressed.connect(_on_pressed)
	$AnimationPlayer.play("ready")
	set_process(true)
	
func set_active(active: bool) -> void:
	$MoneyLabel.visible = active
	self.disabled = !active
	
func _ready() -> void:
	$MoneyLabel.text = ""
	$Background.frame = 1
	$MoneyLabel.visible = false
	$ProgressBar.visible = false
	$AnimationPlayer.play("empty")
	dog_tower = get_tree().current_scene.get_node("DogTower")
	set_process(false)
	
func _on_pressed() -> void:
	self.disabled = true
	
	InBattle.money -= spawn_price
	dog_tower.spawn(dog_scene)
	
	$ProgressBar.visible = true
	$Background.frame = 1
	var tween := create_tween()
	tween.tween_method(_tween_progress, 0, 100, $SpawnTimer.wait_time);
	$SpawnTimer.start()

func _tween_progress(value: float) -> void:
	$ProgressBar.value = value

func _on_spawn_ready() -> void:
	$ProgressBar.visible = false
	$Background.frame = 0 if can_afford_dog() else 1
	self.disabled = not can_afford_dog() 
	
func _process(delta: float) -> void:
	self.disabled = not can_afford_dog() 
	$Background.frame = 0 if can_afford_dog() and $SpawnTimer.is_stopped() else 1	

func can_afford_dog():
	return InBattle.money >= spawn_price
