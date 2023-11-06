extends CharacterBody2D

var _damage = 10000
var _sync_data: Dictionary

func setup(global_position: Vector2):
	self.global_position = global_position
	velocity = Vector2(0, 500)
	velocity *= randf_range(1.0, 1.5)

#	_sync_data = { 
#		"object_type": P2PObjectSync.ObjectType.SKILL,
#		"scene": InBattle.SCENE_FIRE_BALL,
#		"instance_id": get_instance_id(),
#	}
#	add_to_group(P2PObjectSync.SYNC_GROUP)
		
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var all_character = get_tree().get_nodes_in_group("characters")
		all_character.kill()
	die()

func die():
	$AnimationPlayer.play("die")
	await get_tree().create_timer(0.7, false).timeout
	queue_free()

#func get_p2p_sync_data() -> Dictionary:
#	_sync_data["position"] = global_position 
#	return _sync_data
#
#func p2p_setup(sync_data: Dictionary) -> void:
#	setup(sync_data['position'], sync_data['skill_user']) 
#
#func p2p_sync(sync_data: Dictionary) -> void:
#	global_position = sync_data['position']
#
#func p2p_remove() -> void:
#	die()
