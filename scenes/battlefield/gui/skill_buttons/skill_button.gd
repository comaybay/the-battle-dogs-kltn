extends Button

var skill_position
var skill_scene: PackedScene
var is_active: bool

var spawn_price: int
var spawn_input_action: String

func is_spawn_ready() -> bool:
	return $SpawnTimer.is_stopped()


func can_spawn():
	return is_spawn_ready() and is_active

func setup(name_id: String, input_action: String, is_active: bool) -> void:
	set_active(is_active)
	spawn_input_action = input_action
	
	$Icon.texture = load("res://resources/images/skills/%s_icon.png" % name_id)
	skill_scene = load("res://scenes/skills/%s/%s.tscn" % [name_id, name_id])
	
	$SpawnTimer.wait_time = Data.skill_info[name_id]['spawn_time']
	$SpawnTimer.timeout.connect(_on_spawn_ready)
	
	spawn_price = Data.skill_info[name_id]['spawn_price']
	
	pressed.connect(_on_pressed)
	$AnimationPlayer.play("ready")
	set_process(true)
	set_process_input(true)
	
func set_active(active: bool) -> void:
	is_active = active
	self.disabled = !active
	
func _ready() -> void:
	$Background.frame = 1
	$ProgressBar.visible = false
	$AnimationPlayer.play("empty")
	skill_position = get_tree().current_scene.get_node("Land")
	set_process(false)
	set_process_input(false)

func _on_spawn_ready() -> void:
	$ProgressBar.visible = false
	
func _process(delta: float) -> void:
	self.disabled = !can_spawn()
	$Background.frame = 0 if  is_spawn_ready() else 1	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(spawn_input_action) and can_spawn():
		spawn_skill()
			
func _on_pressed() -> void:
	spawn_skill()
	
func spawn_skill():
	self.disabled = true
	
	skill_position.spawn(skill_scene) #goi linh ở vị trí vector
	
	$ProgressBar.visible = true
	$Background.frame = 1
	var tween := create_tween()
	tween.tween_method(_tween_progress, 0, 100, $SpawnTimer.wait_time);
	$SpawnTimer.start()

func _tween_progress(value: float) -> void:
	$ProgressBar.value = value
