extends StaticBody2D


func _ready() -> void:
	$CollisionShape2D.shape.extents = Vector2(2000, 20)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
