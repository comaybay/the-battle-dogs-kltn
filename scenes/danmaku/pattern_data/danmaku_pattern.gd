class_name DanmakuPattern extends Node

signal finished

func bake() -> Variant:
	push_error("ERROR: bake() not implemented")
	return []
	
func tween(duration: float, delay: float, callback: Callable) -> Signal:
	push_error("ERROR: tween(duration: float, callback: Callable) not implemented")
	return finished
