extends Node
## This autoload is used for online lobby and p2p battle using Steamworks

# if player is playing the game using Steam
var IS_USING_STEAM: bool

const PACKET_READ_LIMIT: int = 32

var STEAM_ID: int = 0
var STEAM_USERNAME: String = ""
var PASSWORD: String = ""

# lobby
var lobby_id: int = 0
var lobby_members: Array
var data


## game connection
var listen_socket: int = 0

## the other player that connecting to the room owner socket 
var connection_handle: int = 0

func _ready() -> void:
	var INIT: Dictionary = Steam.steamInit(false)
	print("Did Steam initialize?: "+str(INIT))
	
	IS_USING_STEAM = Steam.loggedOn()
	
	if IS_USING_STEAM: #have account
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()
		PASSWORD = "Aa1@" + str( STEAM_ID)		
		if Data.steam_first_login: #register by STEAM_USERNAME(username) and STEAM_ID(password)			
			Data.steam_first_login = false
			Data.user_name = STEAM_USERNAME			
			SilentWolf.Auth.register_player_user_password(STEAM_USERNAME, PASSWORD, PASSWORD)
			SilentWolf.Auth.login_player(STEAM_USERNAME, PASSWORD)
			SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
			SilentWolf.Players.save_player_data(STEAM_USERNAME, Data.save_data)
		#login by STEAM_USERNAME(username) and STEAM_ID(password)
		SilentWolf.Auth.login_player(STEAM_USERNAME, PASSWORD)
		SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
		
		#get silentwolf data		
		var sw_result = await SilentWolf.Players.get_player_data(STEAM_USERNAME).sw_get_player_data_complete
		Data.silentwolf_data = sw_result.player_data
		
		Data.use_sw_data = true
		if Data.silentwolf_data == null :
			SilentWolf.Players.save_player_data(STEAM_USERNAME, Data.save_data)
		Data.save()
			
	else : # don't have account
		pass
		

func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		print("Registration succeeded!")
	else:
		print("Error: " + str(sw_result.error))
		
	if not IS_USING_STEAM:
		set_process_input(false)
		return

	STEAM_ID = Steam.getSteamID()
	STEAM_USERNAME = Steam.getPersonaName()
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)		
	Steam.initRelayNetworkAccess()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
func _on_lobby_chat_update(_lobby_id: int, _change_id: int, _making_change_id: int, chat_state: int) -> void:
	lobby_members.clear()
	for i in range(0, Steam.getNumLobbyMembers(lobby_id)):
		lobby_members.append(Steam.getLobbyMemberByIndex(lobby_id, i)) 
	
func _send_p2p_packet(target: int, packet_data: Dictionary, send_type: Steam.P2PSend, channel: int = 0) -> void:
	var data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)
	Steam.sendP2PPacket(target, data, send_type, channel)

func _send_p2p_packet_all(packet_data: Dictionary, send_type: Steam.P2PSend, channel: int = 0):
	var data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)
	if lobby_members.size() > 1:
		# Loop through all members that aren't you
		for member in lobby_members:
			if member != STEAM_ID:
				Steam.sendP2PPacket(member, data, send_type, channel)

