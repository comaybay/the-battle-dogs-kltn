class_name Tori extends StaticBody2D

const EnergyExpand: PackedScene = preload("res://scenes/effects/energy_expand/energy_expand.tscn")

signal zero_health

var health: int
var max_health: int
var growl_num: int
var next_growl_health: int

func get_effect_global_position() -> Vector2:
	return $Marker2D.global_position

func setup(position_x: float, health: int, growl_num: int) -> void:
	position.x = BaseBattlefield.TOWER_MARGIN + position_x
	self.health = health
	max_health = health
	update_health_label()
	self.growl_num = growl_num
	next_growl_health = max_health - roundi(max_health / (growl_num + 1))

func take_damage(damage: int) -> void:
	if health <= 0:
		return
	
	if not InBattle.in_request_mode:
		health = max(health - damage, 0) 
	
	if health > 0:
		if next_growl_health != 0 and health <= next_growl_health:
			next_growl_health -= roundi(max_health / (growl_num + 1))
			$AnimationPlayer.play("growl")
			$AnimationPlayer.queue("RESET")
			attack()
		else:	
			$AnimationPlayer.play("shake")
	else:
		$AnimationPlayer.play("destroy")
		zero_health.emit()
		collision_layer = 0
		$HealthLabel.visible = false

	update_health_label()

func update_health_label() -> void:
	$HealthLabel.text = "%s/%s HP" % [health, max_health]

func attack() -> void:
	var effect: FXEnergyExpand = EnergyExpand.instantiate()
	effect.setup($FaceMarker.global_position, "on_emitter")
	InBattle.get_battlefield().get_effect_space().add_child(effect)
	
	for dog in get_tree().get_nodes_in_group("dogs"):
		dog.knockback(1.5)
