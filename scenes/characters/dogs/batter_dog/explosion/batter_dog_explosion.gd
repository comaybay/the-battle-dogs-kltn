class_name BatterDogExplosion extends Node2D

const KNOCKBACK_SCALE: float = 1

var _attack_damage: int

func _ready() -> void:
	$Area2D.body_entered.connect(_on_enemy_entered)
	$AnimationPlayer.animation_finished.connect(func(_anim): queue_free())

func setup(global_position: Vector2, attack_damage: int, direction: int) -> void:
	self.global_position = global_position
	_attack_damage = attack_damage
	self.scale.x = direction

func _on_enemy_entered(enemy: Character) -> void:
	enemy.knockback(KNOCKBACK_SCALE)
	enemy.take_damage(_attack_damage)
