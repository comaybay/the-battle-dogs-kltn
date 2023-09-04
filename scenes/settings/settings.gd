class_name Settings extends Control

## Emitted when the "go back" button is pressed. 
## You can use this singal to switch between the current scene and the settings scene
signal goback_pressed

func _ready() -> void:
	$MainSettings.goback_pressed.connect(func() -> void:
		goback_pressed.emit()		
	)
	
	$MainSettings.keybinding_settings_pressed.connect(func() -> void:
		$MainSettings.hide()
		$KeyBidingSettings.show()	
	)
	
	$KeyBidingSettings.goback_pressed.connect(func() -> void:
		$MainSettings.show()
		$KeyBidingSettings.hide()	
	)
