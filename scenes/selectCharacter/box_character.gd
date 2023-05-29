extends Button

var _parent: Node

func setup( parent: Node) -> void:
	_parent = parent	

func _on_pressed():
	self.visible = false
	_parent.sendInfo($ID.text, $TextureRect.texture,$Type.text)

