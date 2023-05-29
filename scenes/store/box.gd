extends Button

var _parent: Node

func setup( parent: Node) -> void:
	_parent = parent	

func _on_pressed():
	_parent.sendInfo($ID.text,$Name.text,$Detail.text, $Amount.text, $Price.text,$Max.text)
	
