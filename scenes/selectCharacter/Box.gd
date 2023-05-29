extends Button

var _parent: Node

func setup( parent: Node) -> void:
	_parent = parent	

func _on_pressed():
	_parent.deleteInfo($ID.text,$TextureRect.texture, text)
	
