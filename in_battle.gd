extends Node

var _fmoney: float = 0 
var money: int:
	get: return int(_fmoney)
	set(value): _fmoney = clamp(value, 0, max_money) 
	
var max_money: int = 100

## money per second
var money_rate: int = 20


func reset():
	money = 0
	_fmoney = 0
	
func update(delta: float):
	_fmoney = min(_fmoney + (money_rate * delta), max_money)
