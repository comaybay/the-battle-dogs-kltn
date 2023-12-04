class_name ShrineMaidenBattlefield extends Battlefield

func _ready() -> void:
	super._ready()
	$Reflection.setup(land)
	$Tori.setup(_battlefield_data['tori_position'], _battlefield_data['tori_health'], _battlefield_data['tori_growl'])
	cat_tower.position.x = get_stage_width() + TOWER_MARGIN;
	cat_tower.setup($Tori)
