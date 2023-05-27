extends Button

var item_id: String
var _parent: Node
var _item_data: Dictionary

func get_item_data() -> Dictionary:
	return _item_data

func setup(data: Dictionary, parent: Node) -> void:
	_item_data = data
	_parent = parent
	item_id = data['ID']
	$TextureRect.texture = load(data["path"])

func _on_pressed():
	_parent.sendInfo(self, _item_data)


