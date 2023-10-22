class_name OnlineBattleGUI extends CanvasLayer

@onready var spawn_buttons: Control = %P2PSpawnButtons
@onready var money_label: Label = $MoneyLabel
@onready var skill_buttons: Control = %P2PSkillButtons
@onready var efficiency_up_button: TextureButton = $EfficiencyUpButton
@onready var pause_button: TextureButton = $PauseButton
@onready var camera_control_buttons: CameraControlButtons = $CameraControlButtons

var _player_data: P2PBattlefieldPlayerData

func setup(dog_tower: P2PDogTower, player_data: P2PBattlefieldPlayerData):
	%P2PSpawnButtons.setup(dog_tower, player_data)
	%P2PSkillButtons.setup(dog_tower, player_data)
	_player_data = player_data
	
func _ready() -> void:
	$PauseButton.pressed.connect(_on_paused)
	
func _process(_delta: float) -> void:
	$MoneyLabel.text = "%s/%s ₵" % [_player_data.get_money_int(), _player_data.get_wallet_capacity()]	

func _on_paused() -> void:
	$PauseMenu.show()
	get_tree().paused = true
	AudioPlayer.play_button_pressed_audio()
