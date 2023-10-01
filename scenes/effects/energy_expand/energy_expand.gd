extends Sprite2D

## anim_type can be "on_cat" or "on_emitter"
func setup(anim_type: String) -> void:
	$AnimationPlayer.play(anim_type)

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(func(_name: String): queue_free())
