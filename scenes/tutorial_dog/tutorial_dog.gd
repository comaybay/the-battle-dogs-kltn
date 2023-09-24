class_name TutorialDog extends Control
## The tutorial dog that appears when the player is in battle for the first time
##
## Note on the AnimationPlayer's "jump_in_left/right_side" animation:[br]
## The DiaglogueLabel and SpeechBubblePointer are both visible and move out of camera
## instead of just simply be hidden is because objects that are hidden won't emit signals,
## but we need to listen to those signals in the code (in this case, it is
## the DialogueLabel's resized signal).

const BARK_SOUND: AudioStream = preload("res://resources/sound/dog_bark.wav") 

signal dialogue_started
signal dialogue_ended
signal dialogue_line_changed (line_index: int)

enum PLACEMENT { LEFT, RIGHT }

@onready var bubble_pointer_offset_y: float = ($DialogueLabel.position.y + $DialogueLabel.size.y) - $SpeechBubblePointer.position.y 
@onready var original_label_y: float = $DialogueLabel.position.y

var _dialogue_index: int = 0;
var _dialogue_code: String = ""
var _placement: PLACEMENT

func _handle_next_line() -> void:
	if _has_next_dialogue_line():
		AudioPlayer.play_custom_sound(BARK_SOUND, randf_range(1, 1.2))
		_dialogue_next_line()
	else:
		end_dialogue()
		
func _ready() -> void:
	$DialogueLabel.gui_input.connect(func(event):
		if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			_handle_next_line()
	)
	
	$DogButton.pressed.connect(_handle_next_line)
	
	set_process_input(false)
	
	$DialogueLabel.resized.connect(_update_bubble)

## Update bubble pointer position relative to DialogueLabel
func _update_bubble():
	var min_size: Vector2 = $DialogueLabel.get_minimum_size()
	$DialogueLabel.position.y = original_label_y - (min_size.y / 2)
	$DialogueLabel.size.y = min_size.y
	$SpeechBubblePointer.position.y = ($DialogueLabel.position.y + $DialogueLabel.size.y) - bubble_pointer_offset_y

## This will pop up the tutorial dog, and start the dialouge
## dialogue_code is used to get the dialogue lines of certain part of the tutorial
## pause_game: will pause the game while tutorial dog is active
func start_dialogue(dialogue_code: String, placement: PLACEMENT, pause_game: bool = true) -> void:
	_dialogue_index = 0
	_dialogue_code = dialogue_code
	_placement = placement
	show()

	if pause_game:
		get_tree().paused = true
		
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var left_side := _placement == PLACEMENT.LEFT
	_dialogue_next_line()
	## update bubble pointer on first line to ensure it is in correct position
	_update_bubble()
	
	$IntroSound.play()
	$AnimationPlayer.play("jump_in_left_side" if left_side else "jump_in_right_side")
	
	await $AnimationPlayer.animation_finished
	
	set_process_input(true)
	$AnimationPlayer.play("dog_idle")

	dialogue_started.emit()	
	
## Stop the dialogue and hide the tutorial dog
func end_dialogue() -> void:
	_dialogue_index = 0
	set_process_input(false)

	$OutroSound.play()	
	var left_side := _placement == PLACEMENT.LEFT
	$AnimationPlayer.play("jump_out_left_side" if left_side else "jump_out_right_side")
	await $AnimationPlayer.animation_finished
	
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	dialogue_ended.emit()	
	hide()
	
## Pause the dialogue (user can't proceed the dialogue)
func pause_dialogue() -> void:
	set_process_input(false)

## Go to next dialouge line, returns the index of the dialogue line 
func _dialogue_next_line() -> void:
	_dialogue_index += 1
	$DialogueLabel.text = tr("@%s_%s" % [_dialogue_code, _dialogue_index])
	_update_bubble()	
	dialogue_line_changed.emit(_dialogue_index)

func _has_next_dialogue_line() -> bool:
	var code = "@%s_%s" % [_dialogue_code, _dialogue_index + 1]
	return tr(code) != code
