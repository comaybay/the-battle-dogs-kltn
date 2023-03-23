@tool
class_name FSM extends Node

## Finite State Machine.
##
## This node uses it's owner as the target 

@export var initial_state: NodePath = ""

var state: FSMState

func _ready():
	owner.connect("ready", on_owner_ready)
	
func on_owner_ready():
	state = get_node(initial_state)
	
	for node in get_children():
		if node.is_FSM_state == true:
			node.connect("transition", on_state_transition)
			
	state.enter({})

func on_state_transition(next_state_name: String, data: Dictionary = {}):
	state.exit()
	state = get_node(next_state_name)
	state.enter(data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if Engine.is_editor_hint():
		return
			
	state.update(delta)
	
func _input(event: InputEvent) -> void:
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
