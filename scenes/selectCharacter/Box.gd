extends Button


func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	get_tree().current_scene.deleteInfo($ID.text,$TextureRect.texture, text, $Name_id.text)
