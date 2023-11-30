class_name Ofuda extends Bullet

func setup(global_position: Vector2, velocity: Vector2, damage: int, color: OfudaColor, character_type: Character.Type):

	var battlefield := InBattle.get_battlefield() as BaseBattlefield
	_limit_right = battlefield.get_stage_width() + BaseBattlefield.TOWER_MARGIN * 2 + OUTSIDE_MARGIN
	_limit_top = -(battlefield.get_stage_height() + OUTSIDE_MARGIN)
	
	body_entered.connect(_on_body_entered)
	_velocity = velocity
	_damage = damage
	self.global_position = global_position
	
	if character_type == Character.Type.CAT:
		self.scale.x = -self.scale.x
		collision_mask = 0b10

	$Sprite2D.frame = 0 if color == OfudaColor.RED else 1
	
func _on_body_entered(body: Node2D) -> void:	
	InBattle.add_hit_effect(global_position)
	AudioPlayer.play_in_battle_sfx(MikoDog.HIT_SFX)
	queue_free()
	
	if not InBattle.in_request_mode and body is Character:
		body.take_damage(_damage)
		
