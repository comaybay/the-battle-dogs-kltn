class_name KeyBindingListener extends Panel

## User canceled key binding request 
signal canceled(action: String)

## Listening successful, action and requested input is given
signal ok(action: String, input: InputEvent)

var _action: String
var _event: InputEvent = null

## Setup the key binding listener
## action: the action code. eg: "ui_confirm", "ui_cancel"
func setup(action: String):
	_action = action
	%ActionLabel.text = tr("@KEY_" + action) + " "

func _ready() -> void:
	%CancelButton.pressed.connect(func() -> void:
		AudioPlayer.play_button_pressed_audio()
		canceled.emit()
		queue_free()
	)
	
	%ConfirmButton.pressed.connect(func() -> void:
		AudioPlayer.play_button_pressed_audio()
		ok.emit(_action, _event)
		queue_free()
	)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel_default"):
		AudioPlayer.play_button_pressed_audio()
		canceled.emit()
		queue_free()
		
	_event = event
	%InputLabel.text = event.as_text()

	%ButtonContainer.show()
