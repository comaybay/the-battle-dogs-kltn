extends Node
## This autoload is used for online lobby and p2p battle using Steamworks

# if player is playing the game using Steam
var IS_USING_STEAM: bool
const LOBBY_MAX_MEMBERS: int = 2

const PACKET_READ_LIMIT: int = 32

var STEAM_ID: int = 0
var STEAM_USERNAME: String = ""

var lobby_id: int = 0
var lobby_members: Array = []
var data

func _ready() -> void:
	
	var INIT: Dictionary = Steam.steamInit(false)
	print("Did Steam initialize?: "+str(INIT))
	
	IS_USING_STEAM = Steam.loggedOn()
	
	if IS_USING_STEAM: #have account
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()
		if Data.steam_first_login:
			Data.steam_first_login = false
			SilentWolf.Auth.register_player_user_password(STEAM_USERNAME, STEAM_ID, STEAM_ID)
			SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
	else : # don't have account
		
		print("éo")

func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		print("Registration succeeded!")
	else:
		print("Error: " + str(sw_result.error))
