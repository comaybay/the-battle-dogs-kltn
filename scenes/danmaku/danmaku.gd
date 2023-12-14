extends Node

## manage bullet kits, will be used by DanmakuSpace to load in bullets
var bullet_kits :=  BulletKits.new()

## manage patterns, will be clear when DanmakuSpace exit the scene tree 
var patterns: Array[DanmakuPattern] = []

## returns a circular pattern, remeber to queue free it when done
func pattern_cirle(origin: Vector2, radius: float) -> DanmakuPatternCircle:
	var pattern := DanmakuPatternCircle.new()
	pattern.origin = origin
	pattern.radius = radius
	patterns.append(pattern)
	return pattern 

func _process(delta: float) -> void:
	for pattern: DanmakuPattern in patterns:
		if pattern.get_reference_count() <= 2 and not pattern.is_starting():
			patterns.erase(pattern)
			
		if pattern.is_starting():
			pattern._process(delta)

func get_bullet_kit(bullet_kit_resource_path: String, color: BulletKits.BulletColor = BulletKits.BulletColor.UNIQUE) -> DanmakuBulletKit:
	return bullet_kits.get_kit(bullet_kit_resource_path, color)	
