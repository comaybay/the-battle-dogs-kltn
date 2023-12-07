extends Node

var patterns: Array[Dictionary] = []

## returns a circular pattern, remeber to queue free it when done
func pattern_cirle(origin: Vector2, radius: float) -> DanmakuPatternCircle:
	var pattern := DanmakuPatternCircle.new()
	pattern.origin = origin
	pattern.radius = radius
	add_child(pattern)
	return pattern 
