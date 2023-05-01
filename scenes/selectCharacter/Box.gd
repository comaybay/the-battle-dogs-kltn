extends Button

var existing_texture = get_theme_stylebox("normal")

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	owner.Box.sendInfo(1)
