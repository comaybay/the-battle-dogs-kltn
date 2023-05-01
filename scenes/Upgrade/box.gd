extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	#print($TextureRect.texture)
	get_tree().current_scene.sendInfo($Code.text,$Detail.text, $Level.text)
	pass # Replace with function body.

