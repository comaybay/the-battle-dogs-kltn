extends Sprite2D

var _character : Character
## anim_type can be "on_cat" or "on_tower"
func setup(time : float, character : Character ) -> void:
	_character = character
	$AnimationPlayer.play("play")
	_character.tree_exiting.connect(func(): queue_free())
	await get_tree().create_timer(time).timeout
	queue_free()

func _process(delta):
	var width = 0
	var scale = 1
	if (_character != null):
		width = _character.size_character[1] - 50
		scale = _character.size_character[0] /200
		self.global_position = _character.global_position + Vector2(-5,-width)
		self.scale = Vector2(scale,scale)
