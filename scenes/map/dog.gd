extends AnimatedSprite2D

var current_level: Level
var level_queue: Array[Level]
var tween: Tween
var tween_duration: float

func _ready() -> void:
	play("default")

func setup(selected_level: Level, tracker: Tracker):
	current_level = selected_level
	global_position = current_level.global_position + current_level.pivot_offset
	tracker.move_level.connect(_on_move_level)
	
func _on_move_level(target_level: Level):
	if target_level == current_level:
		level_queue = []
		return
		
	var prev_levels: Array[Level] = []
	var next_levels: Array[Level] = []
	
	var prev := current_level.prev_level
	var next := current_level.next_level
	
	while(prev != null or next != null):
		if prev != null:
			prev_levels.append(prev)
			if prev != target_level:
				prev = prev.prev_level
			else:
				break
			
		if next != null:
			next_levels.append(next)
			if next != target_level:
				next = next.next_level
			else:
				break
	
	level_queue = prev_levels if prev == target_level else next_levels
	tween_duration = 0.5 / (1 + (level_queue.size() - 1) * 0.5)
	
	if tween == null or !tween.is_running():
		moving()
	
func moving():
	var level: Level = level_queue.pop_front()
	if level == null:
		return

	scale.x = abs(scale.x) if level.global_position.x > current_level.global_position.x else -abs(scale.x) 
	current_level = level
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", level.global_position + level.pivot_offset, tween_duration)
	tween.tween_callback(moving)
	
	
