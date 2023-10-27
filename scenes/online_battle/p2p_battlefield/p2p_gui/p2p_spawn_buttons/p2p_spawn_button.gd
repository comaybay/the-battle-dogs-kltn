class_name OnlineSpawnButton extends SpawnButton

# 10ms
const ERROR_MARGIN_EPSILON = 0.01 

var _p2p_networking: BattlefieldP2PNetworking

func _ready() -> void:
	var battlefield = get_tree().current_scene as P2PBattlefield
	
	battlefield.ready.connect(func():
		_p2p_networking = battlefield.get_p2p_networking()
		_p2p_networking.spawn_recharge_time_updated.connect(_on_spawn_recharge_time_updated)
		_p2p_networking.spawn_request_accepted.connect(_on_spawn_request_accepted)
	)
	
	super._ready()
	
func _on_spawn_pressed() -> void:
	_p2p_networking.request_spawn(dog_id)
	
func _on_spawn_request_accepted(dog_id: String) -> void:
	if dog_id == self.dog_id:
		_start_recharge_ui()

func _on_spawn_recharge_time_updated(dog_id: String, time_left: float) -> void:
	if (
		dog_id != self.dog_id
		or abs($SpawnTimer.time_left - time_left) <= ERROR_MARGIN_EPSILON
		or time_left <= 0.05 and $SpawnTimer.time_left <= time_left
	):
		return

	$SpawnTimer.stop()
	$SpawnTimer.wait_time = time_left if time_left > 0.05 else 0.05  
	$SpawnTimer.start()
