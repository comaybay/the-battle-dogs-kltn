@tool
extends FSMState

@onready var tutorial_dog: TutorialDog = owner

func enter(data: Dictionary) -> void:
	await get_tree().create_timer(0.5).timeout
	tutorial_dog.start_dialogue("TUTORIAL_TEAM_SETUP", TutorialDog.PLACEMENT.RIGHT, false)
	tutorial_dog.dialogue_ended.connect(func(): 
		owner.queue_free()
		Data.has_done_team_setup_tutorial = true
		Data.save()
	)
