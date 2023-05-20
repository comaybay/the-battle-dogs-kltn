extends CanvasLayer

func _process(_delta: float) -> void:
	$MoneyLabel.text = "%s/%s ₵" % [InBattle.money, InBattle.max_money]
