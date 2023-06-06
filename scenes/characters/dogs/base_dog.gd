class_name BaseDog extends Character

# id used to retrive save infomation of a dog character
@export var name_id: String 

func _ready() -> void:
	super._ready()
	
	var dog_upgrade = Data.dogs[name_id]
	
	if dog_upgrade != null:
		var scale = (1 + dog_upgrade['level'] * 0.2)
		damage *= scale  
		health *= scale
