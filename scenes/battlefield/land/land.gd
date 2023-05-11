extends StaticBody2D

func _ready() -> void:
	var stage_width = InBattle.battlefield_data["stage_width"]
	$CollisionShape2D.shape.extents = Vector2(stage_width / 2, 20)
	$TextureRect.size.x = stage_width
	$TextureRect.position.x = -stage_width / 2
