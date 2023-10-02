extends Node
## This autoload is used for online lobby and p2p battle using Steamworks

# if player is playing the game using Steam
var IS_USING_STEAM: bool

const MESSAGE_READ_LIMIT: int = 32

var STEAM_ID: int = 0
var STEAM_USERNAME: String = ""

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
	
	if not IS_USING_STEAM:
		set_process_input(false)
		return

	STEAM_ID = Steam.getSteamID()
	lobby_members = [STEAM_ID]
	STEAM_USERNAME = Steam.getPersonaName()
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)		
	Steam.initRelayNetworkAccess()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
func _on_lobby_chat_update(_lobby_id: int, _change_id: int, _making_change_id: int, chat_state: int) -> void:
	lobby_members.clear()
	for i in range(0, Steam.getNumLobbyMembers(lobby_id)):
		lobby_members.append(Steam.getLobbyMemberByIndex(lobby_id, i)) 
		print("STEAM_USER LOBBY MEMBERS: " % lobby_members)
	
func send_message(packet_data: Dictionary, send_type: SteamUser.SendType) -> void:
	var data: PackedByteArray = var_to_bytes(packet_data).compress(FileAccess.COMPRESSION_GZIP)
	Steam.sendMessageToConnection(connection_handle, data, send_type)
	
func read_messages():
	var arr: Array = Steam.receiveMessagesOnConnection(connection_handle, MESSAGE_READ_LIMIT)
	for dict in arr:
		dict['data'] = bytes_to_var(dict['payload'].decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
		print(dict)
	
	return arr

func get_lobby_data(key: String) -> String:
	return Steam.getLobbyData(SteamUser.lobby_id, key)
