class_name ItemStoreBox extends Control

var _item_data: Dictionary
func get_item_data() -> Dictionary:
	return _item_data

var _item_id: String
func get_item_id() -> String:
	return _item_id

var _parent: Node	
var stylebox_override: StyleBoxFlat

func _ready():
	stylebox_override = $Button.get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0xbde300FF)

func setup(data: Dictionary, parent: Node) -> void:
	_item_data = data
	_parent = parent
	_item_id = data['ID']
	$TextureRect.texture = load(data["path"])
	update_labels()
	$Button.pressed.connect(_on_pressed)
	
		
func update_labels():
	var amount = get_amount()
	$Amount.text = "x%s" % amount
	$Price.text = str(get_price())
	
func _on_pressed():
	_parent.sendInfo(self, _item_data)

func set_selected(selected: bool):
	if selected:
		$Button.add_theme_stylebox_override("normal", stylebox_override)
		$Button.add_theme_stylebox_override("hover", stylebox_override)
	else:
		$Button.remove_theme_stylebox_override("normal")
		$Button.remove_theme_stylebox_override("hover")

func get_price() -> int:
	return _item_data['price']

func get_max() -> int:
	if !Data.store_info.has(_item_id):
		return 0
	else: 
		return Data.store_info[_item_id]['max']

func get_amount() -> int:
	if !Data.store.has(_item_id):
		return 0
	else: 
		return Data.store[_item_id]['amount']
