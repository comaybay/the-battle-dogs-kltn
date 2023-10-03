extends Node

func _init() -> void:
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	var is_owner: bool = SteamUser.STEAM_ID == owner_id
	
	if is_owner:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_server)
	else:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_client)

func _on_network_connection_status_changed_server(connection_handle: int, connection: Dictionary, old_state: int):
	var new_state: int = connection['connection_state']
	print("====")
	print("NET_WORK_CHANGED:SERVER")
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

func _on_network_connection_status_changed_client(connection_handle: int, connection: Dictionary, old_state: int):
	print("====")
	print("NET_WORK_CHANGED:CLIENT")
	print(old_state)
	print(connection)
	
	var new_state: int = connection['connection_state']
	
	# connection accepted
	if (
		(old_state == Steam.CONNECTION_STATE_CONNECTING or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE) 
		and new_state == Steam.CONNECTION_STATE_CONNECTED
	):
		print("CLIENT: connection re-established.")
		SteamUser.connection_handle = connection_handle
	
	# connection rejected	
	if old_state == Steam.CONNECTION_STATE_CONNECTING and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("CLIENT: connection rejected.")
		_close_connection(connection_handle)

	# disconnected
	if new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY:
		print("CLIENT: disconnected, reconnecting...")
		$Popup.popup("@RECONNECTING", PopupDialog.Type.PROGRESS)
		_close_connection(connection_handle)
		_reconnect_to_listen_socket()

	# listening socket closed (owner of room left):
	if old_state == Steam.CONNECTION_STATE_CONNECTED and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("CLIENT: connection closed owner left.")
		_close_connection(connection_handle)
		$Popup.popup("@OTHER_PLAYER_LEFT", PopupDialog.Type.INFORMATION)

func _reconnect_to_listen_socket():
	print("CONNECTING TO LISTEN SOCKET")
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	Steam.addIdentity("room_owner")
	Steam.setIdentitySteamID64("room_owner", owner_id)
	print(Steam.connectP2P("room_owner", 0, []))	
		
func _close_connection(connection_handle: int):
	Steam.closeConnection(connection_handle, Steam.CONNECTION_END_REMOTE_TIMEOUT, "CLOSE CONNECTION", false)
	print("CLOSE CONNECTION: " + str(connection_handle))
	Steam.clearIdentity("room_owner")
	SteamUser.connection_handle = 0
