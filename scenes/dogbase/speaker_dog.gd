extends Control

@onready var original_size: Vector2 = $DialogueLabel.size
@onready var original_y: float = $SpeechBubblePointer.position.y
var dialogue_count: int

const TRANSLATION: Translation = preload("res://resources/translations/translations_speaker_dog.vi.translation") 
const BUBBLE_SOUND: AudioStream = preload("res://resources/sound/battlefield/spawn.wav") 

func _ready() -> void:
	dialogue_count = TRANSLATION.get_translated_message_list().size()
	
	pick_random_dialogue()
	$DogButton.pressed.connect(pick_random_dialogue)
	
	$DialogueLabel.resized.connect(func(): 
		$SpeechBubblePointer.position.y = original_y + ($DialogueLabel.size.y - original_size.y)
	)
	
	$DialogueLabel.gui_input.connect(func(event):
		if event is InputEventMouseButton && event.pressed && event.button_index == 1:
			AudioPlayer.play_custom_sound(BUBBLE_SOUND)
			pick_random_dialogue()
	)

func pick_random_dialogue():
	$DialogueLabel.text = tr("@SPEAKER_DOG_%s" % randi_range(1, dialogue_count))
	
	
