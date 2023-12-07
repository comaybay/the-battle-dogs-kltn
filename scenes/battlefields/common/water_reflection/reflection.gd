extends Sprite2D

func _ready() -> void:
	item_rect_changed.connect(_on_item_rect_changed)

func setup(land: Land) -> void:
	var land_size := land.get_size()
	scale.x = land_size.x / get_rect().size.x
	_on_item_rect_changed() 

func _process(delta: float) -> void:
	(material as ShaderMaterial).set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)

func _on_item_rect_changed() -> void:
	(material as ShaderMaterial).set_shader_parameter("scale", scale)
