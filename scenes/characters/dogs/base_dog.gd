@tool
class_name BaseDog extends Character

# id used to retrive save infomation of a dog character
@export var name_id: String 
# Kiem tra xem nhan vat co dang bi dieu khien hay khong
var is_user_control 
var check_hover

func _ready() -> void:
	$Arrow.position =  Vector2(0,0)
	$Arrow.position.y = -round($CollisionShape2D.shape.extents.y * 2)
	$Arrow.hide()
	super._ready()
	
	if Engine.is_editor_hint():
		return
	
	var dog_upgrade = Data.dogs[name_id]
	
	if dog_upgrade != null:
		var scale = (1 + (dog_upgrade['level'] - 1) * 0.2)
		damage *= scale  
		health *= scale
		
	super._reready()
	
	is_user_control = false
	check_hover = 0


func _on_mouse_entered():
	check_hover = 1
	if is_user_control == false :
		$Arrow.show()

func _on_mouse_exited():
	check_hover = 0
	if is_user_control == false :
		$Arrow.hide()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed :		
		set_control()

func set_control() :
	if is_user_control == false : # player can control dog
		var dogs: Array[Node] = get_tree().get_nodes_in_group("dogs")
		for dog in dogs:
			dog.is_user_control = false			
			dog.get_node("Arrow").hide()
			dog.get_node("Arrow").self_modulate =  Color.RED			
			dog.get_node("FiniteStateMachine").change_state("MoveState")
		is_user_control = true
		$Arrow.self_modulate =  Color.YELLOW
		$Arrow.show()
		$FiniteStateMachine.change_state("UserMoveState")
		
	else : # set dog to auto fight
		$Arrow.self_modulate =  Color.RED
		$Arrow.hide()		
		is_user_control = false
		$FiniteStateMachine.change_state("MoveState")
	



