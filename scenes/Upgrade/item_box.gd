class_name ItemBox extends Control

var _item_data: Dictionary
func get_item_data() -> Dictionary:
	return _item_data

var _item_id: String
func get_item_id() -> String:
	return _item_id

var _type: String
func get_item_type() -> String:
	return _type
	
var _parent: Node	
var stylebox_override: StyleBoxFlat

func _ready():
	$AnimationPlayer.play("ready")
	stylebox_override = $Button.get_theme_stylebox("normal").duplicate()
	stylebox_override.border_color = Color.hex(0xbde300FF)

func setup(data: Dictionary, type: String, parent: Node) -> void:
	_item_data = data
	_parent = parent
	_type = type
	_item_id = data['ID']
	if type == "skill":
		$Icon.texture = load("res://resources/images/skills/%s_icon.png" % data["ID"])
	else:
		$Icon.texture = load("res://resources/icons/%s_icon.png" % data["ID"])
		
	update_labels()
	$Button.pressed.connect(_on_pressed)
	
		
func update_labels():
	var level = get_level()
	
	$Level.visible = true if level > 0 else false
	$Level.text = "Level. %s" % level
	$Price.text = str(get_price())
	
func _on_pressed():
	_parent.sendInfo(self)

func set_selected(selected: bool):
	if selected:
		$Button.add_theme_stylebox_override("normal", stylebox_override)
		$Button.add_theme_stylebox_override("hover", stylebox_override)
	else:
		$Button.remove_theme_stylebox_override("normal")
		$Button.remove_theme_stylebox_override("hover")

func get_price() -> int:
	return int(_item_data['price'] + (_item_data['price'] * get_level() * 1.5))

func get_level() -> int:
	if !Data.dogs.has(_item_id) and !Data.skills.has(_item_id):
		return 0
	
	if _type == "skill":
		return Data.skills[_item_id]['level']
	else:		
		return Data.dogs[_item_id]['level']
