extends Node
## This autoload is used for online lobby and p2p battle using Steamworks

# if player is playing the game using Steam
var IS_USING_STEAM: bool
const LOBBY_MAX_MEMBERS: int = 2

const PACKET_READ_LIMIT: int = 32

var STEAM_ID: int = 0
var STEAM_USERNAME: String = ""
var PASSWORD: String = ""

var lobby_id: int = 0
var lobby_members: Array = []

func _ready() -> void:
	
	var INIT: Dictionary = Steam.steamInit(false)
	print("Did Steam initialize?: "+str(INIT))
	
	IS_USING_STEAM = Steam.loggedOn()
	
	if IS_USING_STEAM: #have account
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()
		PASSWORD = "Aa1@" + str( STEAM_ID)
		print(Data.steam_first_login)
		if Data.steam_first_login: #register by STEAM_USERNAME(username) and STEAM_ID(password)
			Data.steam_first_login = false
			Data.save()
			SilentWolf.Auth.register_player_user_password(STEAM_USERNAME, PASSWORD, PASSWORD)
			SilentWolf.Auth.login_player(STEAM_USERNAME, PASSWORD)
			SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
			print("dang ky")
		SilentWolf.Auth.login_player(STEAM_USERNAME, PASSWORD)
		SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
		print("dang nhap")
		#get silentwolf data
		get_silentwolf_player_data(STEAM_USERNAME)
		if Data.silentwolf_data == null :
			print("data trong")
	else : # don't have account
		pass
		

func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		print("Registration succeeded!")
	else:
		print("Error: " + str(sw_result.error))

func save_silentwolf_player_data(player_name : String, player_data : Dictionary) -> void:
	SilentWolf.Players.save_player_data(player_name, player_data)

func get_silentwolf_player_data(player_name : String) :
	Data.silentwolf_data = await SilentWolf.Players.get_player_data(player_name).sw_get_player_data_complete
	print("Player data: " + str(Data.silentwolf_data.player_data))
