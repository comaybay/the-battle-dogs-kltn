extends StaticBody2D

func _ready() -> void:
	var parent: Battlefield = get_parent()
	$CollisionShape2D.shape.extents = Vector2(parent.stage_width / 2, 20)
	$TextureRect.size.x = parent.stage_width
	$TextureRect.position.x = -parent.stage_width / 2
