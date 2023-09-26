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
	
	if IS_USING_STEAM:
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()
