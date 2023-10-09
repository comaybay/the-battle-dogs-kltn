extends BattlefieldP2PNetworking

const UPDATE_INTERVAL: float = 1/30
const TEAM_SIZE: int = 10

var _this_player_data: OnlineBattlefieldPlayerData
var _opponent_data: OnlineBattlefieldPlayerData
var _this_player_dog_tower: OnlineDogTower
var _opponent_dog_tower: OnlineDogTower

var _delta_passed: float = 0
var _received_message_number: int = 0
var _client_efficiency_upgrade_request_accepted: bool = 0

## used to keep track of client's summon box's recharge time
var _client_spawn_timers := {}

## oppoonent dog instances, this will be cleared everytime an authoritative message is sent
var _opponent_dog_instances := {}

## this player dog instances, this will be cleared everytime an authoritative message is sent
var _this_player_dog_instances := {}

## instances of zero health dogs used to confirm to client what dogs to kill,
## this will be cleared everytime an authoritative message is sent
var _zero_health_dog_instances: Array[int] = []

var _attacking_dog_instances: Array[int] = []

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
	_opponent_dog_tower = opponent_dog_tower
	_this_player_dog_tower = this_player_dog_tower
	
	for dog_id in opponent_player_data.team_dog_ids:
		if dog_id == null:
			continue
			
		var timer: = Timer.new()
		timer.wait_time = Data.dog_info[dog_id]['spawn_time']
		timer.one_shot = true		
		_client_spawn_timers[dog_id] = timer
		add_child(timer)
	
	set_process(true)
	
func _process(delta: float):
	_this_player_data.update(delta)	
	_opponent_data.update(delta)
	
	_apply_client_messages()
	
	# input are send every frame
	if _this_player_data.input_mask != 0:
		SteamUser.send_message({
			'opponent_input_mask': _this_player_data.input_mask,
		}, SteamUser.SendType.RELIABLE)
		_this_player_data.input_mask = 0
	
	# authoritative message are in a fixed interval (tick)
	_delta_passed += delta
	if _delta_passed >= UPDATE_INTERVAL:
		_delta_passed -= UPDATE_INTERVAL
		var message := {
			'fmoney': _opponent_data.fmoney,
			'received_message_number': _received_message_number
		}
		
		if _client_efficiency_upgrade_request_accepted:
			message['efficiency_level'] = _opponent_data.get_efficiency_level()
			_client_efficiency_upgrade_request_accepted = false
		
		if _opponent_dog_instances.size() > 0:
			message['spawn'] = _opponent_dog_instances
			
		if _this_player_dog_instances.size() > 0:
			message['opponent_spawn'] = _this_player_dog_instances
		
		if _zero_health_dog_instances.size() > 0:
			message['zero_health_dogs'] = _zero_health_dog_instances
			
		if _attacking_dog_instances.size() > 0:
			message['sync_attack_state_dogs'] = _attacking_dog_instances
		
		var client_recharge_times = []
		for i in range(TEAM_SIZE):
			var dog_id = _opponent_data.team_dog_ids[i]
			if dog_id != null:
				var time_left: float = (_client_spawn_timers[dog_id] as Timer).time_left
				client_recharge_times.append(time_left)
				
		if client_recharge_times.size() > 0:
			message['recharge_times'] = client_recharge_times
		
		var dogs = get_tree().get_nodes_in_group("dogs")
		if dogs.size() > 0: 
			message['dog_states'] = dogs.map(func(dog: BaseDog): 
				return { "instance_id": dog.get_instance_id(), "position": dog.position, "health": dog.health }
			)
			
		SteamUser.send_message(message, SteamUser.SendType.RELIABLE)
		
		_opponent_dog_instances.clear()
		_this_player_dog_instances.clear()
		_zero_health_dog_instances.clear()
		_attacking_dog_instances.clear()

func _apply_client_messages():
	for message in SteamUser.read_messages():
		var data: Dictionary = message['data']
		_received_message_number = data['message_number']
		
		var input_mask: int = data['input_mask']
		_handling_client_spawn(input_mask)
		_handling_efficiency_upgrade(input_mask)

func _handling_client_spawn(input: int):
	for i in range(0, 10):
		var input_mask: int = (1 << i)
		var request_spawn: bool = input & input_mask == input_mask
		if not request_spawn or _opponent_data.team_dog_ids[i] == null:
			continue
			
		var dog_id = _opponent_data.team_dog_ids[i]
		var timer := _client_spawn_timers[dog_id] as Timer
		var spawn_ready: bool = timer.is_stopped()
		if not spawn_ready:
			continue
		
		var spawn_price: int = Data.dog_info[dog_id]['spawn_price']
		var can_afford: bool = _opponent_data.get_money_int() >= spawn_price
		if can_afford:
			_opponent_data.fmoney -= spawn_price
			var dog: BaseDog = _opponent_dog_tower.spawn(_opponent_data.team_dog_ids[i])	
			_connect_dog_signals(dog)
			_opponent_dog_instances[dog.name_id] = dog.get_instance_id()
			timer.start()
			
func _handling_efficiency_upgrade(input_mask: int):
	var request_upgrade: bool = input_mask & (1 << 13) == (1 << 13)
	if not request_upgrade:
		return
		
	var upgrade_price: int = _opponent_data.get_efficiency_upgrade_price() 
	var can_upgrade: bool = _opponent_data.get_money_int() >= upgrade_price
	if can_upgrade:
		_opponent_data.fmoney -= upgrade_price
		_opponent_data.increase_efficiency_level()
		_client_efficiency_upgrade_request_accepted = true

func request_efficiency_upgrade():
	if _this_player_data.get_efficiency_level() < _this_player_data.MAX_EFFICIENCY_LEVEL:
		_this_player_data.fmoney -= _this_player_data.get_efficiency_upgrade_price()
		_this_player_data.increase_efficiency_level()
	
	upgrade_efficiency_request_accepted.emit()
	
func request_spawn(dog_id: String):
	var spawn_price: int = Data.dog_info[dog_id]['spawn_price']
	_this_player_data.fmoney -= spawn_price
	
	var dog = _this_player_dog_tower.spawn(dog_id)
	_connect_dog_signals(dog)
	
	if _this_player_dog_instances.has(dog.name_id):
		_this_player_dog_instances[dog.name_id] = dog.get_instance_id()
	else:
		_this_player_dog_instances[dog.name_id] = [dog.get_instance_id()]
	
	spawn_request_accepted.emit(dog_id)

func _connect_dog_signals(dog: BaseDog):
	dog.zero_health.connect(_on_dog_zero_health.bind(dog))		
	dog.get_FSM().state_entered.connect(_on_dog_state_changed.bind(dog))

func _on_dog_zero_health(dog: BaseDog):
	_zero_health_dog_instances.append(dog.get_instance_id())

func _on_dog_state_changed(state_path: String, dog: BaseDog):
	if state_path == "AttackState":
		_attacking_dog_instances.append(dog.get_instance_id())
