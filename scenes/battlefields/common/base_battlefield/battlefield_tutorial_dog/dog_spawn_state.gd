extends FSMState

@onready var tutorial_dog: BattlefieldTutorialDog = owner
var gui: BattleGUI 
# called when the state is activated
func enter(data: Dictionary) -> void:
	gui = tutorial_dog.get_battlefield_gui()
	
	tutorial_dog.get_dog_tower().dog_spawn.connect(_on_dog_spawn, CONNECT_ONE_SHOT)

func _on_dog_spawn(dog: BaseDog):	
	var camera := tutorial_dog.get_camera()
	camera.process_mode = Node.PROCESS_MODE_ALWAYS
	camera.allow_user_input_camera_movement(false)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "position", dog.position, 1)
	
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	tutorial_dog.start_dialogue("TUTORIAL_DOG_SPAWN", tutorial_dog.PLACEMENT.RIGHT)
	tutorial_dog.dialogue_line_changed.connect(_on_next_line)
	tutorial_dog.dialogue_ended.connect(_on_diaglogue_ended, CONNECT_ONE_SHOT)
	
	await tween.finished

var action_index: int = 0
var actions: Array[Dictionary] = [
	{ 
		"index": 4, 
		"enter": func(): gui.efficiency_up_button.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): gui.efficiency_up_button.z_index = 0
	},
	{ 
		"index": 5, 
		"enter": func(): gui.spawn_buttons.switch_row_button.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): gui.spawn_buttons.switch_row_button.z_index = 0
	},
	{ 
		"index": 6, 
		"enter": func(): gui.skill_buttons.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): return
	},
	{ 
		"index": 7, 
		"enter": func(): return,
		"exit": func(): gui.skill_buttons.z_index = 0
	},
	{ 
		"index": 8, 
		"enter": func(): gui.game_speed_button.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): gui.game_speed_button.z_index = 0
	},
	{ 
		"index": 9, 
		"enter": func(): gui.camera_control_buttons.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): gui.camera_control_buttons.z_index = 0
	},
	{ 
		"index": 11, 
		"enter": func(): gui.pause_button.z_index = RenderingServer.CANVAS_ITEM_Z_MAX,
		"exit": func(): gui.pause_button.z_index = 0
	},
]

func _on_next_line(index: int) -> void:
	if action_index == actions.size():
		actions[action_index - 1]["exit"].call()
		tutorial_dog.dialogue_line_changed.disconnect(_on_next_line) 
		return
		
	if index != actions[action_index]["index"]:
		return
	
	if action_index > 0:
		actions[action_index - 1]["exit"].call()
	
	actions[action_index]["enter"].call()
	action_index += 1
		
func _on_diaglogue_ended():
	transition.emit("CatSpawnState")
