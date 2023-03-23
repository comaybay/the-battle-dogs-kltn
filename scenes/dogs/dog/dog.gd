extends CharacterBody2D

@export var speed = 200
@export var attack_range = 150

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimationPlayer.play("walk")
	$RayCast2D.target_position = Vector2(attack_range, 0)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var collider = $RayCast2D.get_collider()
	if collider == null:
		velocity.x = speed
		
	else:
		velocity = Vector2.ZERO
		$AnimationPlayer.play("attack")
		
	move_and_slide()
 
