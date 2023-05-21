@tool
extends FSMState

var start_attack := false
const HitFx := preload("res://scenes/effects/hit_fx/hit_fx.tscn")

# called when the state is activated
func enter(_data: Dictionary) -> void:
	character.n_Sprite2D.frame_changed.connect(on_frame_changed)
	character.n_AnimationPlayer.animation_finished.connect(on_animation_finished)
	character.n_AnimationPlayer.play("attack")

func on_frame_changed() -> void:
	if character.n_Sprite2D.frame == character.attack_frame:
		start_attack = true

func physics_update(_delta: float) -> void:
	if start_attack == false:
		return
		
	$Danh.play()
	# custom attack
	if character.custom_attack_area != null:
		for target in character.custom_attack_area.get_overlapping_bodies():
			print(target)
			target.take_damage(character.damage)
	
	# single target
	elif character.attack_area_range <= 0:
		# target can be a dog or a dog tower
		var target := character.n_RayCast2D.get_collider()
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
		
		# target can be a dog or a dog tower
		for result in results:
			result.collider.take_damage(character.damage)
			
	var target := character.n_RayCast2D.get_collider()
	if target != null:
		create_attack_fx(character.n_RayCast2D.get_collision_point())
	
	start_attack = false

func create_attack_fx(global_position: Vector2):	
	var hit_fx: HitFx = HitFx.instantiate()
	get_tree().current_scene.get_node("EffectSpace").add_child(hit_fx)
	hit_fx.global_position = global_position
			
func on_animation_finished(_name):	
	print(character.n_AttackCooldownTimer.wait_time)
	character.n_AttackCooldownTimer.start()
	transition.emit("IdleState")
		
# called when the state is deactivated
func exit() -> void:
	character.n_Sprite2D.frame_changed.disconnect(on_frame_changed) 
	character.n_AnimationPlayer.animation_finished.disconnect(on_animation_finished)


