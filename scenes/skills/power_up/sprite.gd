extends Sprite2D

var _character : Character
## anim_type can be "on_cat" or "on_tower"
func setup(time : float, character : Character ) -> void:
	_character = character
	$AnimationPlayer.play("on_cat")
	await get_tree().create_timer(time).timeout
	queue_free()

func _process(delta):
	if (_character != null):
		self.global_position = _character.global_position
