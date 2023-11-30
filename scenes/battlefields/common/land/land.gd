class_name Land extends StaticBody2D

# This is to avoid characters falling out of the world when knockback to far out of the battle
const OUTER_PADDING = 2000 

func _ready() -> void:
	var battlefield := InBattle.get_battlefield()
	var stage_width_with_margin = battlefield.get_stage_width() + (BaseBattlefield.TOWER_MARGIN * 2)
	
	var shape_extents_x = (stage_width_with_margin + OUTER_PADDING * 2) / 2
	$CollisionShape2D.shape.extents.x = shape_extents_x
	$CollisionShape2D.position.x = stage_width_with_margin / 2
	$TextureRect.size.x = stage_width_with_margin 

func get_size() -> Vector2:
	return $TextureRect.size
