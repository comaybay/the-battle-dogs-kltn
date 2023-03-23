extends CharacterBody2D

class_name Cat

@export var speed = 200
@export var attack_range = 150

## in seconds
@export var attack_cooldown = 2

@onready var n_RayCast2D := $RayCast2D as RayCast2D
@onready var n_AnimationPlayer := $AnimationPlayer as AnimationPlayer
@onready var n_Sprite2D := $Sprite2D as Sprite2D
@onready var n_AttackCooldownTimer := $AttackCooldownTimer as Timer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	n_AttackCooldownTimer.wait_time = attack_cooldown
