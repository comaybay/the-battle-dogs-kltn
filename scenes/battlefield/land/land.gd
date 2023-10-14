class_name Land extends StaticBody2D

# This is to avoid characters falling out of the world when knockback to far out of the battle
const OUTER_PADDING = 2000 

func _ready() -> void:
	var battlefield = get_tree().current_scene as BaseBattlefield
	$TextureRect.texture = load("res://resources/battlefield_themes/%s/land.png" % battlefield.get_theme())
	var stage_width_with_margin = battlefield.get_stage_width() + (BaseBattlefield.TOWER_MARGIN * 2)
	
	var shape_extents_x = (stage_width_with_margin + OUTER_PADDING * 2) / 2
	$CollisionShape2D.shape.extents = Vector2(shape_extents_x, 20)
	$CollisionShape2D.position.x = stage_width_with_margin / 2
	$TextureRect.size.x = stage_width_with_margin 

func spawn(scene: PackedScene) -> void:
	var skill = scene.instantiate()
	get_tree().current_scene.add_child(skill)
