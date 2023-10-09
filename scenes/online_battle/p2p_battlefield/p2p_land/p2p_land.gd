class_name OnlineLand extends Land

func _ready() -> void:
	$TextureRect.texture = load("res://resources/battlefield_themes/%s/land.png" % Steam.getLobbyData(SteamUser.lobby_id, "theme"))
	var stage_width = int(Steam.getLobbyData(SteamUser.lobby_id, "stage_width"))
	$CollisionShape2D.shape.extents = Vector2(OUTER_PADDING + stage_width / 2, 20)
	$TextureRect.size.x = stage_width
	$TextureRect.position.x = -stage_width / 2

