extends Node

var battlefield_data: Dictionary

var _fmoney: float = 0 
var money: int:
	get: return int(_fmoney)
	set(value): _fmoney = clamp(value, 0, _wallet) 

const STAGE_WIDTH_MARGIN = 300
const MAX_EFFICIENCY_LEVEL = 8
const BASE_WALLET_CAPACITY = 100
const BASE_EFFICIENCY_UPGRADE_PRICE = 40
const BASE_MONEY_RATE = 15
	
var _wallet: int = BASE_WALLET_CAPACITY
func get_wallet_capacity():
	return _wallet

var _efficiency_upgrade_price = BASE_EFFICIENCY_UPGRADE_PRICE
func get_efficiency_upgrade_price() -> int:
	return _efficiency_upgrade_price	

## money per second
var _money_rate: int = BASE_MONEY_RATE

var _efficiency_level: int = 1
func get_efficiency_level():
	return _efficiency_level

func reset():
	_fmoney = 0
	_wallet = BASE_WALLET_CAPACITY * (1 + _get_level_or_zero(Data.passives.get('wallet_capacity')) * 0.5)
	_money_rate = BASE_MONEY_RATE * (1 + _get_level_or_zero(Data.passives.get('money_efficiency')) * 0.1)
	_efficiency_upgrade_price = BASE_EFFICIENCY_UPGRADE_PRICE * (1 + _get_level_or_zero(Data.passives.get('money_efficiency')) * 0.1)
	_efficiency_level = 1
	
func _get_level_or_zero(dict: Variant) -> int:
	return 0 if dict == null else dict.get('level', 0)
	
func update(delta: float):
	var efficiency = 1 + ((_efficiency_level - 1) * 0.05)
	_fmoney = min(_fmoney + (_money_rate * efficiency * delta), _wallet)

func load_battlefield_data() -> Dictionary:
	var file = FileAccess.open("res://resources/battlefield_data/%s.json" % Data.selected_battlefield_id, FileAccess.READ)
	battlefield_data = JSON.parse_string(file.get_as_text())
	battlefield_data['stage_width'] += STAGE_WIDTH_MARGIN * 2
	file.close()
	return battlefield_data

func increase_efficiency_level() -> void:
	_efficiency_level += 1
	_wallet *= 2
	_efficiency_upgrade_price *= 2
	
func can_afford_efficiency_upgrade() -> bool:
	return money >= get_efficiency_upgrade_price()

func get_cat_power_scale() -> float:
	var scale = battlefield_data.get('power_scale')
	return scale if scale != null else 1
