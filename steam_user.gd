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
		lobby_members = [STEAM_ID]
		PASSWORD = "Aa1@" + str( STEAM_ID)
		Steam.initRelayNetworkAccess()
		#register by STEAM_USERNAME(username) and STEAM_ID(password)			
		var sw_result = await SilentWolf.Auth.register_player_user_password(STEAM_USERNAME, PASSWORD, PASSWORD).sw_registration_user_pwd_complete		
		if sw_result.success :
			print("dang ky")
			dang_ky_sw()
		dang_nhap_sw()
	
	if not IS_USING_STEAM:
		set_process_input(false)
		
	else : # don't have account
		pass
	

func dang_ky_sw():
	var file := FileAccess.open("res://resources/new_game_save.json", FileAccess.READ)
	var new_game_save_text: Dictionary = JSON.parse_string(file.get_as_text())	
	file.close()
	new_game_save_text["date"] = Time.get_datetime_string_from_system()
	new_game_save_text['user_name'] = STEAM_USERNAME
	await SilentWolf.Players.save_player_data(STEAM_USERNAME, new_game_save_text)
	SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
	#get silentwolf data		
	if Data.user_name == "":
		Data.user_name = STEAM_USERNAME

func dang_nhap_sw():	
	var sw_result = await SilentWolf.Players.get_player_data(STEAM_USERNAME).sw_get_player_data_complete
	Data.silentwolf_data = sw_result.player_data
	if (STEAM_USERNAME == Data.old_data["user_name"]) or (Data.old_data["user_name"] == "") :		
		Data.save_data["user_name"] = STEAM_USERNAME
		print("dang nhap1 : ",Data.save_data.date)
		print("dang nhap1 : ",Data.silentwolf_data.date)
		var date1 = Time.get_unix_time_from_datetime_string(Data.save_data.date)
		var date2 = Time.get_unix_time_from_datetime_string(Data.silentwolf_data.date)
		print("dang1 : ",date1)
		print("dang1 : ",date2)
		if date2 > date1: #luu silentwolf_data vao data
			Data.save_data = Data.silentwolf_data
			print("dang1")
		else : #luu data vao silentwolf_data			
			SilentWolf.Players.save_player_data(STEAM_USERNAME, Data.save_data)
			Data.silentwolf_data = Data.save_data
			print("dang2")
		Data.save()
	else :
		Data.select_data.emit()

func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		print("Registration succeeded!")
	else:
		print("Error: " + str(sw_result.error))


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
