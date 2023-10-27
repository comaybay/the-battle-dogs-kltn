extends Control

@onready var chat_box := %ChatBox as ChatBox 

var _prev_owner_id: int = 0

var _prev_music_settings: String = ""
var _prev_theme_settings: String = ""

func _ready() -> void:
	SteamUser.update_lobby_members()
	SteamUser.connection_handle = 0
	%CustomBattlefieldSettings.settings_changed.connect(_on_battlefield_settings_changed)

	%RoomNameLabel.text = SteamUser.get_lobby_data("name")
	%RoomIdLabel.text = "%s: %s" % [tr("@ROOM_ID"), SteamUser.lobby_id]

	%GoBackButton.pressed.connect(func():
		_handle_connection_leave_lobby()
		_go_back_to_lobby_scene()
	)	
	
	%CopyButton.pressed.connect(func(): DisplayServer.clipboard_set(str(SteamUser.lobby_id)))
	%ReadyButton.pressed.connect(_on_toggle_ready)
	%StartButton.pressed.connect(_send_start_message)
	
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.persona_state_change.connect(func(_id, _flags): _update_lobby_ui())
	
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	_prev_owner_id = owner_id
	
	var is_room_owner: bool = SteamUser.STEAM_ID == owner_id
	if is_room_owner:
		Steam.setLobbyMemberData(SteamUser.lobby_id, "ready", "true")
		_create_listen_socket()
		
		var default_battlefield_settings = [
			[CustomBattlefieldSettings.TYPE_STAGE_WIDTH, CustomBattlefieldSettings.DEFAULT_STAGE_WIDTH],
			[CustomBattlefieldSettings.TYPE_DOG_TOWER_HEALTH, CustomBattlefieldSettings.DEFAULT_DOG_TOWER_HEALTH],
			[CustomBattlefieldSettings.TYPE_MONEY_EFFICIENCY_LEVEL, CustomBattlefieldSettings.DEFAULT_EFFICIENCY_LEVEL],
			[CustomBattlefieldSettings.TYPE_POWER_LEVEL, CustomBattlefieldSettings.DEFAULT_POWER_LEVEL],
			[CustomBattlefieldSettings.TYPE_MUSIC, CustomBattlefieldSettings.DEFAULT_MUSIC],
			[CustomBattlefieldSettings.TYPE_THEME, CustomBattlefieldSettings.DEFAULT_THEME]
		]
		for settings in default_battlefield_settings:
			SteamUser.set_lobby_data(settings[0], str(settings[1]))
			%CustomBattlefieldSettings.set_settings(settings[0], settings[1])
			
	else:
		Steam.setLobbyMemberData(SteamUser.lobby_id, "ready", "false")
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_room_member)
		_connect_to_listen_socket()
	
	Steam.setLobbyMemberData(SteamUser.lobby_id, "team_setup", JSON.stringify(Data.teams[0]))
	
	_update_lobby_ui()

## disabled starting game button until the settings is updated to the lobby
func _on_battlefield_settings_changed(type: String, value: Variant) -> void:
	%StartButton.disabled = true 
	SteamUser.set_lobby_data(type, str(value))

func _on_toggle_ready() -> void:
	var is_ready := SteamUser.get_member_data(SteamUser.STEAM_ID, "ready") == "true"
	Steam.setLobbyMemberData(SteamUser.lobby_id, "ready", "false" if is_ready else "true")

func _on_lobby_data_update(success: int, lobby_id: int, member_id: int) -> void:
	if success == 0 or member_id != lobby_id:
		return
	
	_update_lobby_ui()	
		
	var music: String = SteamUser.get_lobby_data(CustomBattlefieldSettings.TYPE_MUSIC)
	if music != _prev_music_settings:
		_prev_music_settings = music
		var prev_music = AudioPlayer.get_current_music()
		if prev_music != null:
			AudioPlayer.stop_music(prev_music, true)
			AudioPlayer.remove_music(prev_music)
		
		AudioPlayer.play_music(load("res://resources/sound/music/%s.mp3" % music))
		
	var battlefield_theme: String = SteamUser.get_lobby_data(CustomBattlefieldSettings.TYPE_THEME)
	if battlefield_theme != _prev_theme_settings:
		_prev_theme_settings = battlefield_theme
		%BG.texture = load("res://resources/battlefield_themes/%s/sky.png" % battlefield_theme) 

	if SteamUser.get_lobby_data("game_start") == "true":
		$Popup.popup("@STARTING_GAME", PopupDialog.Type.PROGRESS)
		chat_box.display_message(tr("@STARTING_GAME"), ChatBox.COLOR_P2P_EVENT)
		await get_tree().process_frame
		_go_to_game()

func _update_lobby_ui() -> void:
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	var is_room_owner: bool = SteamUser.STEAM_ID == owner_id
	
	%CustomBattlefieldSettings.set_editable(is_room_owner)

	%PlayerSlot1.setup(owner_id)
	if SteamUser.lobby_members.size() <= 1:
		%PlayerSlot2.setup_empty()
	else:
		var first_member_is_room_owner: bool = SteamUser.lobby_members[0] == owner_id
		%PlayerSlot2.setup(
			SteamUser.lobby_members[1] if first_member_is_room_owner else SteamUser.lobby_members[0]
		)
	
	if is_room_owner:		
		%ReadyButton.hide()
		%StartButton.show()
		%GoBackButton.disabled = false
		
		var member_not_connected: bool = SteamUser.connection_handle == 0
		var member_not_ready: bool = SteamUser.lobby_members.any(
			func(member: int): return SteamUser.get_member_data(member, "ready") == "false"
		) 
		%StartButton.disabled = member_not_connected or member_not_ready
	else:
		%ReadyButton.show()
		%StartButton.hide()

		var is_ready := SteamUser.get_member_data(SteamUser.STEAM_ID, "ready") == "true"
		%ReadyButton.text = "@UNREADY" if is_ready else "@READY"  
		%GoBackButton.disabled = is_ready
		
		update_custom_battlefield_settings_ui_room_member()

func update_custom_battlefield_settings_ui_room_member():
	# updpate the settings set by the room owner
	for type in CustomBattlefieldSettings.TYPES:
		var value: String = SteamUser.get_lobby_data(type)
		if value == "":
			continue
		
		if type == CustomBattlefieldSettings.TYPE_MUSIC or type == CustomBattlefieldSettings.TYPE_THEME:
			%CustomBattlefieldSettings.set_settings(type, SteamUser.get_lobby_data(type))
		else:
			%CustomBattlefieldSettings.set_settings(type, int(SteamUser.get_lobby_data(type)))

func _on_lobby_chat_update(lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	SteamUser.update_lobby_members()
	var username: String = Steam.getFriendPersonaName(change_id)
	# if a player has left the lobby and the player was a lobby owner
	if chat_state == 2 and _prev_owner_id == change_id:
		print("%s %s" % [username, tr("@PLAYER_HAS_LEFT")])
		_close_connection(SteamUser.connection_handle)
		
		# let new room owner create connection, while others connect to the room
		var new_owner := Steam.getLobbyOwner(SteamUser.lobby_id)
		var new_owner_username := Steam.getFriendPersonaName(new_owner)
		var new_owner_message := "%s %s" % [new_owner_username, tr("@IS_NEW_ROOM_OWNER")]
		chat_box.display_message(new_owner_message, ChatBox.COLOR_LOBBY_EVENT)
	
		if new_owner == SteamUser.STEAM_ID:
			Steam.network_connection_status_changed.disconnect(_on_network_connection_status_changed_room_member)
			Steam.setLobbyMemberData(SteamUser.lobby_id, "ready", "true")
			_create_listen_socket()
		else:
			_connect_to_listen_socket()
	
	_update_lobby_ui()
	
func _handle_connection_leave_lobby():
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	var is_room_owner: bool = SteamUser.STEAM_ID == owner_id
	
	if is_room_owner and SteamUser.listen_socket != 0:
		print("CLOSE SOCKET %s" % SteamUser.listen_socket)
		Steam.closeListenSocket(SteamUser.listen_socket)
		SteamUser.connection_handle = 0
		SteamUser.listen_socket = 0
	else:
		_close_connection(SteamUser.connection_handle)
	
	print("LEAVE LOBBY %s" % SteamUser.lobby_id)
	Steam.leaveLobby(SteamUser.lobby_id)
	SteamUser.lobby_id = 0
	# Close session with all users
	for member_id in SteamUser.lobby_members:
		if SteamUser.STEAM_ID != member_id:
			Steam.closeP2PSessionWithUser(member_id)

func _go_back_to_lobby_scene():	
	var current_music = AudioPlayer.get_current_music()
	if current_music != null:
		AudioPlayer.stop_music(current_music, true)
		AudioPlayer.remove_music(current_music)
	
	get_tree().change_scene_to_file("res://scenes/online_battle/lobby/lobby.tscn")	

func _send_start_message():
	SteamUser.set_lobby_data("game_start", "true")
	
func _go_to_game():
	var current_music = AudioPlayer.get_current_music()
	if current_music != null:
		AudioPlayer.stop_music(current_music, true)
		AudioPlayer.remove_music(current_music)
		
	get_tree().change_scene_to_file("res://scenes/online_battle/p2p_battlefield/p2p_battlefield.tscn")	

func _on_network_connection_status_changed_room_owner(connection_handle: int, connection: Dictionary, old_state: int):	
	print("=".repeat(10))
	print("NET_WORK_CHANGED:ROOM_OWNER")
	print("handle: %s" % connection_handle)
	print("old_state: %s" % old_state)
	print("new_state: %s" % connection['connection_state'])
	
	var new_state: int = connection['connection_state']
	# example: steamid:76561199486434807" -> 76561199486434807
	var steam_id: int = int(connection['identity'].get_slice(":", 1))
	var username: String = Steam.getFriendPersonaName(steam_id)
			
	# A new connection arrives on a listen socket
	if old_state == Steam.CONNECTION_STATE_NONE and new_state == Steam.CONNECTION_STATE_CONNECTING:
		print("ROOM_OWNER: ACCEPT CONNECTION %s" % connection_handle)
		Steam.acceptConnection(connection_handle)
		var message := "%s %s" % [tr("@CONNECTING_TO_PLAYER"), username]
		chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)
		return
	
	var old_state_equals_connecting: bool = (
		old_state == Steam.CONNECTION_STATE_CONNECTING 
		or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE
	)
	
	var connection_established = old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_CONNECTED
	if connection_established:
		print("ROOM_OWNER: connection established.")
		SteamUser.connection_handle = connection_handle
		var message := "%s %s" % [tr("@CONNECTION_ESTABLISHED_WITH"), username]
		chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)
		_update_lobby_ui()
		return
		
	# failed to connect
	var failed_to_connect: bool = (
		old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY
	)
	if failed_to_connect:
		print("ROOM_OWNER: failed to connect with peer")
		SteamUser.connection_handle = 0
		var message := "%s %s" % [tr("@FAILED_TO_CONNECT_WITH"), username]
		chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)
		
	# connection closed:
	elif old_state == Steam.CONNECTION_STATE_CONNECTED and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("ROOM_OWNER: connection closed from peer")
		SteamUser.connection_handle = 0
		var message := "%s %s" % [username, tr("@HAS_DISCONNECTED")]
		chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)

func _on_network_connection_status_changed_room_member(connection_handle: int, connection: Dictionary, old_state: int):
	# only process connection handle of the room owner
	if connection_handle != SteamUser.connection_handle:
		return
	
	print("=".repeat(10))
	print("NET_WORK_CHANGED:ROOM_MEMBER")
	print("handle: %s" % connection_handle)
	print("old_state: %s" % old_state)
	print("new_state: %s" % connection['connection_state'])
	
	var new_state: int = connection['connection_state']
	# example: steamid:76561199486434807" -> 76561199486434807
	var steam_id: int = int(connection['identity'].get_slice(":", 1))
	var username: String = Steam.getFriendPersonaName(steam_id)
	
	var old_state_equals_connecting: bool = (
		old_state == Steam.CONNECTION_STATE_CONNECTING 
		or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE
	)
	
	# connection accepted
	if old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_CONNECTED:
		print("MEMBER: connection established.")
		SteamUser.connection_handle = connection_handle
		var message := "%s %s" % [tr("@CONNECTED_ESTABLISHED_WITH"), username]
		chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)
	
	# timeout
	if old_state == Steam.CONNECTION_STATE_CONNECTING and new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY:
		print("MEMBER: connection timout.")
		_handle_connection_leave_lobby()
		$Popup.popup("@LOST_CONNECTION", PopupDialog.Type.INFORMATION)
		await $Popup.ok
		_go_back_to_lobby_scene()

	# listening socket closed (owner of room left):
	if old_state == Steam.CONNECTION_STATE_CONNECTED and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("MEMBER: connection closed owner left. Try connecting to new owner of room")
		var message := "%s %s" % [tr("@CONNECTION_CLOSED_BY"), username]
		chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)

func _close_connection(connection_handle: int):
	Steam.closeConnection(connection_handle, Steam.CONNECTION_END_REMOTE_TIMEOUT, "CLOSE CONNECTION", false)
	print("CLOSE CONNECTION: " + str(connection_handle))
	Steam.clearIdentity("room_owner")
	SteamUser.connection_handle = 0

func _connect_to_listen_socket():
	print("CONNECTING TO LISTEN SOCKET")
	var owner_id := Steam.getLobbyOwner(SteamUser.lobby_id)
	var owner_username := Steam.getFriendPersonaName(owner_id)
	var message := "%s %s" % [tr("@CONNECTING_TO"), owner_username]
	chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)
	
	Steam.addIdentity("room_owner")
	Steam.setIdentitySteamID64("room_owner", owner_id)
	SteamUser.connection_handle = Steam.connectP2P("room_owner", 0, [])

func _create_listen_socket():
	var message := "%s %s" % [SteamUser.STEAM_USERNAME, tr("@HAS_CREATED_CONNECTION")]
	chat_box.display_message(message, ChatBox.COLOR_P2P_EVENT)
	
	SteamUser.listen_socket = Steam.createListenSocketP2P(0, [])
	print("new listen socket: %s" % SteamUser.listen_socket)
	Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_room_owner)
