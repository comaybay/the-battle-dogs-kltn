extends Control

var _parent: Node

func setup( parent: Node) -> void:
	_parent = parent	

func _on_pressed():
	self.visible = false
	_parent.sendInfo($ID.text, $Icon.texture,$Type.text)

