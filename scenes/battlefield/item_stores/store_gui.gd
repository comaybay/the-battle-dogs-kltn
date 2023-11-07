class_name StoreGUI extends CanvasLayer

var _player_data: BaseBattlefieldPlayerData
var _dog_tower :DogTower
func setup(dog_tower: DogTower, player_data: BaseBattlefieldPlayerData):
	_player_data = player_data
	var store_ids: Array = _player_data.team_store_ids
	for item in store_ids:
		if (item != null) and (Data.store_info[item]["auto_activate"] == true):
			var index = _player_data.team_store_ids.find(item)
			var store := _player_data.team_store_scenes[index].instantiate()
			get_tree().current_scene.add_child(store)
			store.setup(item)
	

func _on_Launch_nuclear_bomb_pressed():
	Data.store["nuclear_bomb"].amount -= 1
	var index = _player_data.team_store_ids.find("nuclear_bomb")
	var store := _player_data.team_store_scenes[index].instantiate()
	get_tree().current_scene.add_child(store)
	store.setup()
	Data.save()
