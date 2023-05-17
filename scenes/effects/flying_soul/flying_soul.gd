extends Node2D

const FLY_SPEED: int = 700

const FREQ: int = 7
const AMPLITUDE: int = 40
const TIME_TO_LIVE: int = 4

var time: float = 0
var base_position: Vector2 
 
func _ready() -> void:
	$Sound.play()
	$AnimatedSprite.play("default")
	base_position = position

func _process(delta: float) -> void:
	position.y -= FLY_SPEED * delta 
	
	time += delta
	position.x = base_position.x + sin(time * FREQ) * AMPLITUDE
	
	if time >= TIME_TO_LIVE:
		queue_free()
