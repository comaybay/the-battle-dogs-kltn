extends Node
## This autoload is used for online lobby and p2p battle using Steamworks

# if player is playing the game using Steam
var IS_USING_STEAM: bool

const MESSAGE_READ_LIMIT: int = 32

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

enum SendType {
	UNRELIABLE = 0, NO_NAGLE = 1, NO_DELAY = 4, RELIABLE = 8, 
}

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
			SilentWolf.Players.save_player_data(STEAM_USERNAME, Data.save_data)
		#login by STEAM_USERNAME(username) and STEAM_ID(password)
		SilentWolf.Auth.login_player(STEAM_USERNAME, PASSWORD)
		SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
		
		#get silentwolf data		
		var sw_result = await SilentWolf.Players.get_player_data(STEAM_USERNAME).sw_get_player_data_complete
		Data.silentwolf_data = sw_result.player_data
		
		
		Data.use_sw_data = true	
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
	lobby_members = [STEAM_ID]
	STEAM_USERNAME = Steam.getPersonaName()
	Steam.initRelayNetworkAccess()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
func update_lobby_members():
	lobby_members.clear()
	for i in range(0, Steam.getNumLobbyMembers(lobby_id)):
		lobby_members.append(Steam.getLobbyMemberByIndex(lobby_id, i)) 
	print("STEAM_USER: LOBBY MEMBERS: %s " % ",".join(lobby_members))	
		
	
func send_message(packet_data, send_type: SteamUser.SendType) -> void:
	var data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)
	Steam.sendMessageToConnection(connection_handle, data, send_type)
	
func read_messages():
	var arr: Array = Steam.receiveMessagesOnConnection(connection_handle, MESSAGE_READ_LIMIT)
	for dict in arr:
		dict['data'] = bytes_to_var(dict['payload'].decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
	
	return arr

func get_lobby_data(key: String) -> String:
	return Steam.getLobbyData(SteamUser.lobby_id, key)

func set_lobby_data(key: String, value: String) -> void:
	return Steam.setLobbyData(SteamUser.lobby_id, key, value)

func get_member_data(member_id: int, key: String) -> String:
	return Steam.getLobbyMemberData(lobby_id, member_id, key)
	
func get_lobby_owner() -> int:
	return Steam.getLobbyOwner(lobby_id)
