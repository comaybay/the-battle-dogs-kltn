extends Button

var item_id: String
var _parent: Node

func setup(id: String, parent: Node) -> void:
	_parent = parent
	var dog_info = Data.dog_info[id]
	item_id = id
	$ID.text = dog_info['ID']
	$Name.text = dog_info['name']
	$Description.text = dog_info['detail']
	$TextureRect.texture = load(dog_info['path'])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	#print($TextureRect.texture)
	_parent.sendInfo($ID.text,$Description.text ,$Name.text, $Level.text, $Price.text)


