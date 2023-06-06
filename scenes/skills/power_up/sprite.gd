extends Sprite2D

var _character : Character
## anim_type can be "on_cat" or "on_tower"
func setup(time : float, character : Character ) -> void:
	_character = character
	$AnimationPlayer.play("play")
	await get_tree().create_timer(time).timeout
	queue_free()

func _process(delta):
	var width = 0
	if (_character != null):
		width = _character.sizeCharacter[1] - 50
		self.global_position = _character.global_position + Vector2(0,-width)
		self.scale = Vector2(_character.scaleCharacter,_character.scaleCharacter)
