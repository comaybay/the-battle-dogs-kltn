class_name BattlefieldPlayerData extends BaseBattlefieldPlayerData

func _init() -> void:
	team_dog_ids = Data.selected_team['dog_ids'].filter(func(id): return id != null)
	for id in team_dog_ids:
		team_dog_scenes.append(load("res://scenes/characters/dogs/%s/%s.tscn" % [id, id]))
	
	fmoney = 0
	_wallet = int(BASE_WALLET_CAPACITY * (1 + _get_level_or_zero(Data.passives.get('wallet_capacity')) * 0.5))
	_money_rate = int(BASE_MONEY_RATE * (1 + _get_level_or_zero(Data.passives.get('money_efficiency')) * 0.1))
	_efficiency_upgrade_price = BASE_EFFICIENCY_UPGRADE_PRICE * (1 + _get_level_or_zero(Data.passives.get('money_efficiency')) * 0.1)
	_efficiency_level = 1
