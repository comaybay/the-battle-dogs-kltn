extends Node

## use to load battlefield_data
var battlefield_id: String = "doggonamu"

var battlefield_data: Dictionary
var _fmoney: float = 0 
var money: int:
	get: return int(_fmoney)
	set(value): _fmoney = clamp(value, 0, max_money) 
	
var max_money: int = 100

## money per second
var money_rate: int = 10

const STAGE_WIDTH_MARGIN = 300

func reset():
	money = 0
	_fmoney = 0
	
func update(delta: float):
	_fmoney = min(_fmoney + (money_rate * delta), max_money)

func load_battlefield_data() -> Dictionary:
	var file = FileAccess.open("res://resources/battlefield_data/%s.json" % battlefield_id, FileAccess.READ)
	battlefield_data = JSON.parse_string(file.get_as_text())
	battlefield_data['stage_width'] += STAGE_WIDTH_MARGIN * 2
	file.close()
	return battlefield_data
