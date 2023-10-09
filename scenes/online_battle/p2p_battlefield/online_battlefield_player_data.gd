class_name OnlineBattlefieldPlayerData extends BaseBattlefieldPlayerData

## first 10 bit represent the spawn buttons, next 3 represent skill buttons and the 
## last bit represent the efficiency upgrade button 
var input_mask := 0b00000000000000

func _init(team_setup: Dictionary) -> void:
	team_dog_ids = team_setup['dog_ids']
	team_skill_ids = team_setup['skill_ids']
	
	for id in team_dog_ids:
		team_dog_scenes.append(null if id == null else load("res://scenes/characters/dogs/%s/%s.tscn" % [id, id]))
	
	fmoney = 0
	_wallet = int(BASE_WALLET_CAPACITY * (1 + int(SteamUser.get_lobby_data('wallet_capacity_level')) * 0.5))
	_money_rate = int(BASE_MONEY_RATE * (1 + int(SteamUser.get_lobby_data('money_efficiency_level')) * 0.1))
	_efficiency_upgrade_price = BASE_EFFICIENCY_UPGRADE_PRICE * (1 + int(SteamUser.get_lobby_data('money_efficiency_level')) * 0.1)
	_efficiency_level = 1