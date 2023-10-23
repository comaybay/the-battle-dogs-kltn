class_name GandolfgBullet extends CharacterBody2D

const BASE_DAMAGE = 50
const SPEED = 700
var _stop_following: bool = false
var _direction: Vector2 = Vector2(0.5, 0.5) 
var _target: Character

func _ready():
	set_physics_process(false)
	rotation = randi_range(0, 360)
	var tween := get_tree().create_tween()
	tween.set_loops(0)
	tween.tween_property(self, "rotation", 360, 120.0).as_relative()
	tween.bind_node(self)
		
func setup(global_position: Vector2, target: Character) :
	_target = target  
	self.global_position = global_position 
	_calculate_direction()
	
	# Khong thay doi vi tri vien dan nua neu meo da chet hoac dang bi vap nga
	target.tree_exiting.connect(func(): _stop_following = true, CONNECT_ONE_SHOT)
	target.knockbacked.connect(func(): _stop_following = true, CONNECT_ONE_SHOT)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.45).from(Vector2(0, 0))
	await tween.finished
	set_physics_process(true)

func _calculate_direction():
	_direction = (_target.global_position - global_position).normalized()
	
func _physics_process(delta):
	if not _stop_following:
		_calculate_direction()
	
	var collision = move_and_collide(_direction * SPEED * delta)
	if collision:
		var collider := collision.get_collider()
		if collider is Character:
			var level := InBattle.get_passive_level("gandolfg")
			collider.take_damage(BASE_DAMAGE + (level * 10))
		
		InBattle.add_hit_effect(global_position)
		queue_free()
