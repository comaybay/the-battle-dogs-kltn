extends CanvasLayer

func _ready() -> void:
	$PauseButton.pressed.connect(_on_paused)
	

func _process(_delta: float) -> void:
	$MoneyLabel.text = "%s/%s ₵" % [InBattle.money, InBattle.get_wallet_capacity()]
	
#TODO: remove this later when time scale button is implemented
func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("ui_switch_time_scale"):
		Engine.time_scale = 4 if Engine.time_scale < 4 else 1   		

func _on_paused() -> void:
	$PauseMenu.show()
	get_tree().paused = true
	AudioPlayer.play_button_pressed_audio()
