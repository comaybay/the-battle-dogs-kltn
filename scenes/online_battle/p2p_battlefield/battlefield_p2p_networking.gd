class_name BattlefieldP2PNetworking extends Node
## Base code for battlefield p2p networking. 
## A peer will handle input request differently depending whether the peer is a client or server

func _process(delta: float) -> void:	
	push_error("ERROR: _process(delta: float) not implemented")
	return

signal upgrade_efficiency_request_accepted
func request_efficiency_upgrade() -> void:
	push_error("ERROR: request_efficiency_upgrade() not implemented")
	return

signal spawn_request_accepted(dog_id: String)
signal spawn_recharge_time_updated(dog_id: String, time_left: float)
func request_spawn(dog_id: String) -> void:
	push_error("ERROR: request_spawn(dog_id: String) not implemented")
	return

func signal_take_damage(dog_id: String) -> void:
	push_error("ERROR: request_spawn(dog_id: String) not implemented")
	return
