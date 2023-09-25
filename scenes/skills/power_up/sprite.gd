extends Sprite2D

const TOP_PADDING = 20;

var _character : Character
## anim_type can be "on_cat" or "on_tower"
func setup(time : float, character : Character ) -> void:
	_character = character
	$AnimationPlayer.play("play")
	_character.tree_exiting.connect(func(): queue_free())
	await get_tree().create_timer(time, false).timeout
	queue_free()

func _process(delta):
	var collision_rect := _character.collision_rect
	var new_scale := collision_rect.size.x / get_rect().size.x;
	scale = Vector2(new_scale, new_scale)
	self.global_position = _character.global_position
	self.global_position.y += collision_rect.position.y - (collision_rect.size.y / 2) - TOP_PADDING
