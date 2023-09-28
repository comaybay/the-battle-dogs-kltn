class_name PopupDialog extends Control

signal ok
signal confirm
signal cancel

const MAX_POPUP_PANEL_WIDTH = 700

## Types of popup. [br]
## PROGRESS: no buttons, is used as a progress popup telling the player to wait
## INFORMATION: popup with an Ok button
## CONFIRMATION: popup with Yes and Cancel buttons 
enum Type { PROGRESS, INFORMATION, CONFIRMATION }

func _ready() -> void:
	%OkButton.pressed.connect(func(): 
		self.hide()
		ok.emit()
	)
	
	%ConfirmButton.pressed.connect(func(): 
		self.hide()
		confirm.emit()
	)
	
	%CancelButton.pressed.connect(func(): 
		self.hide()
		cancel.emit()
	)

func popup(message: String, popup_type: Type):
	%OkButton.hide()
	%ConfirmationButtons.hide()
	
	if popup_type == Type.INFORMATION:
		%OkButton.show()
	elif popup_type == Type.CONFIRMATION:
		%ConfirmationButtons.show()
			
	%PopupMessage.autowrap_mode = TextServer.AUTOWRAP_OFF
	%PopupMessage.text = ""
	%PopupPanel.size.x = 0
	%PopupMessage.text = message
	
	# auto wrap text if popup panel exceed maxium size
	if %PopupPanel.get_minimum_size().x >= MAX_POPUP_PANEL_WIDTH:
		%PopupMessage.text = ""
		%PopupMessage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		%PopupPanel.size.x = MAX_POPUP_PANEL_WIDTH
		%PopupMessage.text = message
	
	%PopupPanel.anchors_preset = PRESET_CENTER
	self.show()
