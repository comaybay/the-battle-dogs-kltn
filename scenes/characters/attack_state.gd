@tool
extends FSMState

var start_attack := false

# called when the state is activated
func enter(data: Dictionary) -> void:
	character.n_Sprite2D.frame_changed.connect(on_frame_changed)
	character.n_AnimationPlayer.animation_finished.connect(on_animation_finished)
	character.n_AnimationPlayer.play("attack")

func on_frame_changed() -> void:
	if character.n_Sprite2D.frame == character.attack_frame:
		start_attack = true

func physics_update(delta: float) -> void:
	if start_attack == false:
		return
	
	# single target
	if character.attack_area_range <= 0:
		var target := character.n_RayCast2D.get_collider() as Character
		if target != null:
			target.take_damage(character.damage)

	# area attack
	else:
		var space_state := character.get_world_2d().direct_space_state
		# use global coordinates, not local to node
		var shape_id := PhysicsServer2D.rectangle_shape_create()
		PhysicsServer2D.shape_set_data(shape_id, Vector2(character.attack_area_range / 2, 1))
		
		var shape_query := PhysicsShapeQueryParameters2D.new()
		shape_query.shape_rid = shape_id
		
		var attack_midpoint := character.n_RayCast2D.global_position + character.n_RayCast2D.target_position
		shape_query.transform = Transform2D(0, attack_midpoint) 
		
		var results := space_state.intersect_shape(shape_query, 1000)
		
		for result in results:
			result.collider.take_damage(character.damage)
		
	start_attack = false
			
func on_animation_finished(name):
	character.n_AttackCooldownTimer.start()
	transition.emit("IdleState")
		
# called when the state is deactivated
func exit() -> void:
	character.n_Sprite2D.frame_changed.disconnect(on_frame_changed) 
	character.n_AnimationPlayer.animation_finished.disconnect(on_animation_finished)
		
# called every frame when the state is active
func update(delta: float) -> void:
	pass
# this method is the equivalent of _input but only called when the state is active
func input(event: InputEvent) -> void:
	pass 
	

