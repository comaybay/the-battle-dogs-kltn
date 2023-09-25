extends Node2D

const bullet = preload("res://scenes/battlefield/dog_tower/gun/bullet.tscn")
var stage_width
var listCat = []
var cat
func _ready() -> void:
	var battlefield_data = InBattle.load_battlefield_data()
	InBattle.reset()
	stage_width = battlefield_data['stage_width']
	
	$AttackArea/AttackCollisionShape.shape.extents = Vector2(stage_width/2, 8000)
	$AttackArea/AttackCollisionShape.position = Vector2(0, 0)
	
func _process(delta):
	
	if (cat == null) and (listCat.is_empty() == false): #get first cat
		cat = listCat.front()
		listCat.erase(cat)
		
	if  ($AttackCooldownTimer.is_stopped() == true) and (cat != null):		
		var item = bullet.instantiate()
		item.target(cat)
		item.global_position = $Sprite2D.position
		self.add_child(item)
		$AttackCooldownTimer.start()
		
		
	if cat != null: #look gun at target
		look_at(cat.position)
	
func _on_attack_area_body_entered(body):
	if body is BaseCat:
		listCat.push_back(body)
		
