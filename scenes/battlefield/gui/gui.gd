class_name BattleGUI extends CanvasLayer

@onready var spawn_buttons: Control = %SpawnButtons
@onready var money_label: Label = $MoneyLabel
@onready var skill_buttons: Control = %SkillButtons
@onready var efficiency_up_button: TextureButton = $EfficiencyUpButton
@onready var pause_button: TextureButton = $PauseButton
@onready var game_speed_button: GameSpeedButton = $GameSpeedButton
@onready var camera_control_buttons: CameraControlButtons = $CameraControlButtons

func setup(dog_tower: DogTower):
	%SpawnButtons.setup(dog_tower)
	
func _ready() -> void:
	$PauseButton.pressed.connect(_on_paused)
	
func _process(_delta: float) -> void:
	$MoneyLabel.text = "%s/%s ₵" % [InBattle.money, InBattle.get_wallet_capacity()]	

func _on_paused() -> void:
	$PauseMenu.show()
	get_tree().paused = true
	AudioPlayer.play_button_pressed_audio()
