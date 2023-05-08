class_name CharacterButton extends TextureButton

var icon_name: String
var scale_val: float = 1

func init(name_id: String, scale: float ) -> void:
	icon_name = name_id
	scale_val = scale
	
func _ready() -> void:
	scale = Vector2(scale_val, scale_val)
	print(scale)
	pressed.connect(_on_pressed)
	$AnimationPlayer.play("normal")
	$Icon.texture = load("res://resources/icons/%s_icon.png" % icon_name)

func _on_pressed():
	print("BRUH")
