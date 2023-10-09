class_name BaseBattlefieldPlayerData extends Resource

const MAX_EFFICIENCY_LEVEL = 8
const BASE_WALLET_CAPACITY = 100
const BASE_EFFICIENCY_UPGRADE_PRICE = 40
const BASE_MONEY_RATE = 15

var team_dog_ids: Array
var team_dog_scenes: Array[PackedScene]

var team_skill_ids: Array
var team_skills: Array[PackedScene]

var fmoney: float = 0:
	set(value): fmoney = clamp(value, 0, _wallet) 
	
func get_money_int() -> int: return int(fmoney) 

var _wallet: int
func get_wallet_capacity():
	return _wallet

var _efficiency_upgrade_price
func get_efficiency_upgrade_price() -> int:
	return _efficiency_upgrade_price	

## money per second
var _money_rate: int

var _efficiency_level: int
func get_efficiency_level():
	return _efficiency_level

func _get_level_or_zero(dict: Variant) -> int:
	return 0 if dict == null else dict.get('level', 0)
	
func update(delta: float):
	var efficiency = 1 + ((_efficiency_level - 1) * 0.05)
	fmoney = min(fmoney + (_money_rate * efficiency * delta), _wallet)

func increase_efficiency_level() -> void:
	_efficiency_level += 1
	_wallet *= 2
	_efficiency_upgrade_price *= 2

func _init() -> void:
	push_error("ERROR: _init() NOT IMPLEMENTED")
