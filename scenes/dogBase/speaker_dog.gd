extends Control

@onready var original_size: Vector2 = $DialogueLabel.size
@onready var original_y: float = $SpeechBubblePointer.position.y

const BUBBLE_SOUND: AudioStream = preload("res://resources/sound/battlefield/spawn.wav") 

func _ready() -> void:
	pick_random_dialogue()
	$DogButton.pressed.connect(pick_random_dialogue)
	
	$DialogueLabel.resized.connect(func(): 
		$SpeechBubblePointer.position.y = original_y + ($DialogueLabel.size.y - original_size.y)
	)
	
	$DialogueLabel.gui_input.connect(func(event):
		if event is InputEventMouseButton && event.pressed && event.button_index == 1:
			pick_random_dialogue()
	)

func pick_random_dialogue():
	AudioPlayer.play_custom_sound(BUBBLE_SOUND)
	$DialogueLabel.text = Data.speaker_dog_dialogue.pick_random()
	
	
