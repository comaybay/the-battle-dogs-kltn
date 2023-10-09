extends BattlefieldP2PNetworking

var _this_player_data: OnlineBattlefieldPlayerData
var _opponent_data: OnlineBattlefieldPlayerData
var _this_player_dog_tower: OnlineDogTower
var _opponent_dog_tower: OnlineDogTower

## mapping dogs between server and client
var _dog_instance_map := {}

var _message_number: int = 0


func _ready() -> void:
	set_process(false)

func setup(
		this_player_data: OnlineBattlefieldPlayerData, 
		opponent_player_data: OnlineBattlefieldPlayerData, 
		this_player_dog_tower: OnlineDogTower,
		opponent_dog_tower: OnlineDogTower
	):
	_this_player_data = this_player_data
	_opponent_data = opponent_player_data
	_this_player_dog_tower = this_player_dog_tower
	_opponent_dog_tower = opponent_dog_tower
	set_process(true)

func _process(delta: float):	
	for message in SteamUser.read_messages():
		var data: Dictionary = message['data']
		
		# update player state using data sent from server
		if data.has('fmoney'):
			var server_received_message_number: int = data['received_message_number']
			_handling_money(data['fmoney'], server_received_message_number)
		
		## server received upgrade input and accepted it 
		## the updated efficency level is sent back 
		if data.has('efficiency_level'):
			_handling_efficiency_upgrade(data['efficiency_level'])
			
		if data.has('spawn'):
			_handling_this_player_spawn(data['spawn'])
			
		if data.has('recharge_times'):
			_handling_recharge_times(data['recharge_times'])
		
		if data.has('opponent_spawn'):
			_hanlding_opponent_spawn(data['opponent_spawn'])
		
		if data.has('sync_attack_state_dogs'):
			_handling_dog_attack_state_sync(data['sync_attack_state_dogs'])
		
		if data.has('zero_health_dogs'):
			_hanlding_zero_health_dogs(data['zero_health_dogs'])
		
		if data.has('dog_states'):
			_hanlding_dog_states(data['dog_states'])
			
	_this_player_data.update(delta)
	
	# input are send every frame
	if _this_player_data.input_mask != 0:
		_message_number += 1
		SteamUser.send_message({
			'input_mask': _this_player_data.input_mask,
			'message_number': _message_number
		}, SteamUser.SendType.RELIABLE)
		_this_player_data.input_mask = 0

func _handling_money(fmoney: float, server_received_message_number: int):
	# wait until server handle all client messages to update money value.
	# This is to avoid money going down and up and down again when client summons a dog
	if server_received_message_number < _message_number: 
		return
		
	_this_player_data.fmoney = fmoney

func _handling_efficiency_upgrade(level: int):
	var upgrade_count = level - _this_player_data.get_efficiency_level()
	for i in range(0, upgrade_count):
		_this_player_data.increase_efficiency_level()
		
	upgrade_efficiency_request_accepted.emit()

func _handling_this_player_spawn(spawn_data: Dictionary):
	for dog_id in spawn_data:
		var server_instance_id: int = spawn_data[dog_id]
		var dog = _this_player_dog_tower.spawn(dog_id)
		_dog_instance_map[server_instance_id] = dog.get_instance_id()
		spawn_request_accepted.emit(dog_id)

func _handling_recharge_times(recharge_times: Array):
	print(recharge_times)
	var dog_ids = _this_player_data.team_dog_ids.filter(func(dog_id): return dog_id != null)
	for i in range(recharge_times.size()):
		var dog_id: String = dog_ids[i]
		var recharge_time: float = recharge_times[i]
		spawn_recharge_time_updated.emit(dog_id, recharge_time)
		
func _hanlding_opponent_spawn(spawn_data: Dictionary):
	for dog_id in spawn_data:
		for server_instance_id in spawn_data[dog_id]:
			var dog = _opponent_dog_tower.spawn(dog_id)
			_dog_instance_map[server_instance_id] = dog.get_instance_id()

func _handling_dog_attack_state_sync(dog_instances: Array) -> void:
	for server_instance_id in dog_instances:
		print("sync dog: %s" % server_instance_id)
		var dog := instance_from_id(_dog_instance_map[server_instance_id]) as BaseDog
		dog.get_FSM().change_state("AttackState")

func _hanlding_zero_health_dogs(zero_health_dog_instances: Array):
	for server_instance_id in zero_health_dog_instances:
		var dog := instance_from_id(_dog_instance_map[server_instance_id]) as BaseDog
		dog.health = 0
		dog.knockback()
		_dog_instance_map.erase(server_instance_id)
				
func _hanlding_dog_states(dog_states: Array):
	for dog_state in dog_states:
		var server_instance_id: int = dog_state['instance_id']
		
		var client_id = _dog_instance_map.get(server_instance_id)
		
		## skip if the dog is already dead (zero health) in client game		
		if client_id == null:
			continue
		
		var dog := instance_from_id(client_id) as BaseDog
		dog.position = dog_state['position']
		dog.health = dog_state['health']
		
		if dog.is_past_knockback_health():
			dog.update_next_knockback_health()
			dog.knockback() 
			
		if Debug.is_debug_mode():
			dog.queue_redraw()

## send upgrade input to server, waiting for response
func request_efficiency_upgrade():
	_this_player_data.input_mask |= (1 << 13) 

## send spawn input to server, waiting for response
func request_spawn(dog_id: String):
	var index: int = _this_player_data.team_dog_ids.find(dog_id)
	_this_player_data.input_mask |= (1 << index)
