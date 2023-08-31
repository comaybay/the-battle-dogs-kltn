@tool
class_name BaseDog extends Character

# id used to retrive save infomation of a dog character
@export var name_id: String 

var check_hover

func _ready() -> void:
	super._ready()
	var dog_upgrade = Data.dogs[name_id]
	
	if dog_upgrade != null:
		var scale = (1 + (dog_upgrade['level'] - 1) * 0.2)
		damage *= scale  
		health *= scale
		
	super._reready()
	
	check_hover = 0


func _on_mouse_shape_entered():
	print("mouse in") 
	pass # Replace with function body.


func _on_mouse_entered():
	print("mouse iádn") 
	pass # Replace with function body.
