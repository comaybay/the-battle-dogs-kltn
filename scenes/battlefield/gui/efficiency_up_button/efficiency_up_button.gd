extends TextureButton

func _ready() -> void:
	$AnimationPlayer.play("ready")
	$UpgradePriceLabel.text = "%s₵" % InBattle.get_efficiency_upgrade_price()
	pressed.connect(_on_upgrade)

func _process(delta: float) -> void:
	disabled = !InBattle.can_afford_efficiency_upgrade()
	$Background.frame = 1 if disabled else 0	
	
func _on_upgrade() -> void:
	if InBattle.get_efficiency_level() < InBattle.MAX_EFFICIENCY_LEVEL:
		$AudioStreamPlayer.play()
		InBattle.money -= InBattle.get_efficiency_upgrade_price()
		InBattle.increase_efficiency_level()
		$EfficiencyLevelLabel.text = "LV.%s" % InBattle.get_efficiency_level()
		
		if InBattle.get_efficiency_level() == InBattle.MAX_EFFICIENCY_LEVEL:
			$UpgradePriceLabel.text = "MAX"
		else:
			$UpgradePriceLabel.text = "%s₵" % InBattle.get_efficiency_upgrade_price()
