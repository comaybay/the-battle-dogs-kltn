extends Control

var _lobby_members := []

func _ready() -> void:
	%GoBackButton.pressed.connect(_leave_lobby)
	%CopyButton.pressed.connect(func(): DisplayServer.clipboard_set(str(SteamUser.lobby_id)))
	
	%RoomNameLabel.text = Steam.getLobbyData(SteamUser.lobby_id, "name")
	%RoomIdLabel.text = "%s: %s" % [tr("@ROOM_ID"), SteamUser.lobby_id]
	
	%ReadyButton.pressed.connect(_on_toggle_ready)
	%StartButton.pressed.connect(_on_start_game)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.persona_state_change.connect(func(_id, _flags): _update_lobby_ui())
	
	Steam.setLobbyMemberData(SteamUser.lobby_id, "ready", "false")
	
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	var is_owner: bool = SteamUser.STEAM_ID == owner_id
	if is_owner:
		_create_listen_socket()
	else:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_room_member)
		_connect_to_listen_socket()
	
	_update_lobby_ui()
	
func _on_toggle_ready() -> void:
	var ready := Steam.getLobbyMemberData(SteamUser.lobby_id, SteamUser.STEAM_ID, "ready")
	Steam.setLobbyMemberData(SteamUser.lobby_id, "ready", "false" if ready == "true" else "true")

func _on_lobby_data_update(success: int, lobby_id: int, member_id: int) -> void:
	_update_lobby_ui()	

func _update_lobby_ui() -> void:
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	var is_owner: bool = SteamUser.STEAM_ID == owner_id
	
	if is_owner:		
		%ReadyButton.hide()
		%StartButton.show()
	else:
		%ReadyButton.show()
		var ready := Steam.getLobbyMemberData(SteamUser.lobby_id, SteamUser.STEAM_ID, "ready")
		%ReadyButton.text = "@UNREADY" if ready == "true" else "@READY"  
		%StartButton.hide()
	
	var member_count = Steam.getNumLobbyMembers(SteamUser.lobby_id)
	print("LOBBY CHAT UPADTE. owner: %s, member count: %s" % [owner_id, member_count])
	
	if member_count <= 1:
		%PlayerSlot1.setup(SteamUser.STEAM_ID)
		%PlayerSlot2.setup_empty()
		##TODO: uncomment this
#		%StartButton.disabled = true
		%StartButton.disabled = false
		return
	
	%StartButton.disabled = false
	_lobby_members.clear()
	_lobby_members.append(Steam.getLobbyMemberByIndex(SteamUser.lobby_id, 0))
	_lobby_members.append(Steam.getLobbyMemberByIndex(SteamUser.lobby_id, 1))
	%PlayerSlot1.setup(_lobby_members[0])
	%PlayerSlot2.setup(_lobby_members[1])

func _on_lobby_chat_update(lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	var username: String = Steam.getFriendPersonaName(change_id)
	print("LOBBY CHAT UPDATE: " + str(chat_state))
	# If a player has joined the lobby
	if chat_state == 1:
		print("%s %s" % [username, tr("@PLAYER_HAS_JOINED")])

	# Else if a player has left the lobby
	elif chat_state == 2:
		print("%s %s" % [username, tr("@PLAYER_HAS_LEFT")])

	# Else if a player has been kicked
	elif chat_state == 8:
		print("%s %s" % [username, tr("@PLAYER_HAS_BEEN_KICKED")])
		
	_update_lobby_ui()
	
func _leave_lobby():
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	var is_owner: bool = SteamUser.STEAM_ID == owner_id
	if is_owner and SteamUser.listen_socket != 0:
		print("CLOSE SOCKET %s" % SteamUser.listen_socket)
		Steam.closeListenSocket(SteamUser.listen_socket)
		SteamUser.listen_socket = 0
	
	print("LEAVE LOBBY %s" % SteamUser.lobby_id)
	Steam.leaveLobby(SteamUser.lobby_id)
	SteamUser.lobby_id = 0
	# Close session with all users
	for member_id in _lobby_members:
		if SteamUser.STEAM_ID != member_id:
			Steam.closeP2PSessionWithUser(member_id)

	get_tree().change_scene_to_file("res://scenes/online_battle/lobby/lobby.tscn")	

func _on_start_game():
	get_tree().change_scene_to_file("res://scenes/online_battle/online_battlefield/online_battlefield.tscn")	

func _on_network_connection_status_changed_room_owner(connection_handle: int, connection: Dictionary, old_state: int):
	var new_state: int = connection['connection_state']
	print("====")
	print("NET_WORK_CHANGED:ROOM_OWNER")
	print(old_state)
	print(connection)
	
	# A new connection arrives on a listen socket
	if old_state == Steam.CONNECTION_STATE_NONE and new_state == Steam.CONNECTION_STATE_CONNECTING:
		Steam.acceptConnection(connection_handle)
		SteamUser.connection_handle = connection_handle
		print("===")
		print(connection_handle)
		print(connection)
		
	# connection closed:
	if old_state == Steam.CONNECTION_STATE_CONNECTED and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		SteamUser.connection_handle == 0
		print("OWNER: connection closed from peer")

func _on_network_connection_status_changed_room_member(connection_handle: int, connection: Dictionary, old_state: int):
	print("====")
	print("NET_WORK_CHANGED:ROOM_MEMBER")
	print(old_state)
	print(connection)
	
	var new_state: int = connection['connection_state']
	
	# connection accepted
	if (
		(old_state == Steam.CONNECTION_STATE_CONNECTING or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE) 
		and new_state == Steam.CONNECTION_STATE_CONNECTED
	):
		print("MEMBER: connection established.")
		SteamUser.connection_handle = connection_handle
		SteamUser.send_message({"data": "hello"}, SteamUser.SendType.RELIABLE)
	
	# connection rejected	
	if old_state == Steam.CONNECTION_STATE_CONNECTING and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("MEMBER: connection rejected.")
		_close_connection(connection_handle)
		_leave_lobby()

	# timeout
	if old_state == Steam.CONNECTION_STATE_CONNECTING and new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY:
		print("MEMBER: connection timout.")
		_close_connection(connection_handle)
		_leave_lobby()

	# listening socket closed (owner of room left):
	if old_state == Steam.CONNECTION_STATE_CONNECTED and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("MEMBER: connection closed owner left. Try connecting to new owner of room")
		_close_connection(connection_handle)
		
		# let new room owner create connection, while others connect to the room
		var new_owner := Steam.getLobbyOwner(SteamUser.lobby_id)
		if new_owner == SteamUser.STEAM_ID:
			_create_listen_socket()
		else:
			_connect_to_listen_socket()

func _close_connection(connection_handle: int):
	Steam.closeConnection(connection_handle, Steam.CONNECTION_END_REMOTE_TIMEOUT, "CLOSE CONNECTION", false)
	print("CLOSE CONNECTION: " + str(connection_handle))
	SteamUser.connection_handle = 0

func _connect_to_listen_socket():
	print("CONNECTING TO LISTEN SOCKET")
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	Steam.addIdentity(str(owner_id))
	Steam.setIdentitySteamID64(str(owner_id), owner_id)
	print(Steam.connectP2P(str(owner_id), 0, []))

func _create_listen_socket():
	# Create listen socket
	SteamUser.listen_socket = Steam.createListenSocketP2P(0, [])
	print("new listen socket: %s" % SteamUser.listen_socket)
	Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_room_owner)

func _process(delta: float) -> void:
	var arr = SteamUser.read_messages()
	if arr.size() > 0:
		print(arr)
