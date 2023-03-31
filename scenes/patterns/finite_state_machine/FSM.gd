@tool
class_name FSM extends Node

## Finite State Machine.
##
## This node uses it's owner as the target 

@export var initial_state: NodePath = ""

var state: FSMState

func _ready():
	if Engine.is_editor_hint():
		return
		
	owner.connect("ready", _on_owner_ready)
	
func _on_owner_ready():
	state = get_node(initial_state)
	
	for node in get_children():
		if node.is_FSM_state == true:
			node.connect("transition", _on_state_transition)
	
	update_FSM_process()
	state.enter({})

func change_state(next_state_name: String, data: Dictionary = {}):
	state.exit()
	state = get_node(next_state_name)
	state.enter(data)
	update_FSM_process()

func update_FSM_process():
	set_physics_process(state.has_method("physics_update"))
	set_process_input(state.has_method("input"))

func _on_state_transition(next_state_name: String, data: Dictionary = {}):
	change_state(next_state_name, data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if not Engine.is_editor_hint():
		state.update(delta)
	
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		state.physics_update(delta)
	
func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		state.input(event)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []

	var children = get_children()
	if children.size() == 0:
		warnings.append("FSM required at least one state to operate")
		
	elif initial_state.is_empty():
		warnings.append("Please select the Initial State")
	
	for child in children:
		if child.get("is_FSM_state") == null:
			warnings.append("FSM node's children must extends from FSMState script class or has a 'is_FSM_state' property set to 'false' to be ignored by FSM node")
	
	return warnings
