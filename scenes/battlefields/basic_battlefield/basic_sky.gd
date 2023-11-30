extends TextureRect

func _ready() -> void:
	var battlefield := InBattle.get_battlefield() as BasicBattlefield
	$Sky.texture = load("res://resources/battlefield_themes/%s/sky.png" % battlefield.get_theme())
