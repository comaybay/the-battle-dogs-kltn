extends SpawnButton

func spawn_dog() -> BaseDog:
	var dog := super.spawn_dog()
	
	if SteamUser.lobby_members[0] != SteamUser.STEAM_ID:
		_spawn_dog.character_type = Character.Type.ENEMY  
		_spawn_dog._reready()
		
	return dog
