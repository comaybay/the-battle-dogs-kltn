extends Node

const RECONNECT_MAX_TIME: int = 9
var reconnect_loop: int = 0

var _popup: PopupDialog

func _init() -> void:
	var owner_id: int = Steam.getLobbyOwner(SteamUser.lobby_id)
	var is_owner: bool = SteamUser.STEAM_ID == owner_id
	
	if is_owner:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_server)
	else:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_client)

func setup(popup: PopupDialog) -> void:
	_popup = popup

func _on_network_connection_status_changed_server(connection_handle: int, connection: Dictionary, old_state: int):
	print("=".repeat(10))
	print("NET_WORK_CHANGED:SERVER")
	print("handle: %s" % connection_handle)
	print("old_state: %s" % old_state)
	print("new_state: %s" % connection['connection_state'])
	
	var new_state: int = connection['connection_state']
	# example: steamid:76561199486434807" -> 76561199486434807
	var steam_id: int = int(connection['identity'].get_slice(":", 1))
	var username: String = Steam.getFriendPersonaName(steam_id)
			
	# A new connection arrives on a listen socket
	if old_state == Steam.CONNECTION_STATE_NONE and new_state == Steam.CONNECTION_STATE_CONNECTING:
		print("SERVER: ACCEPT CONNECTION %s" % connection_handle)
		Steam.acceptConnection(connection_handle)
		SteamUser.connection_handle = connection_handle
		return
	
	var old_state_equals_connecting: bool = (
		old_state == Steam.CONNECTION_STATE_CONNECTING 
		or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE
	)
	
	var connection_established = old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_CONNECTED
	if connection_established:
		print("SERVER: connection re-established.")
		_popup.close()
		return
		
	# failed to connect
	var failed_to_connect: bool = (
		old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY
	)
	if failed_to_connect:
		print("SERVER: failed to connect with peer")
		SteamUser.connection_handle = 0
		_popup.popup("@RECONNECTING_WITH_OTHER_PLAYER", PopupDialog.Type.PROGRESS)
		if reconnect_loop < RECONNECT_MAX_TIME:
			reconnect_loop += 1
		else:
			#TODO: LET SERVER PEER WIN
			_popup.popup("@OTHER_PLAYER_FAILED_TO_RECONNECT", PopupDialog.Type.INFORMATION)
		
	# connection closed:
	elif old_state == Steam.CONNECTION_STATE_CONNECTED and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("SERVER: connection closed from peer")
		SteamUser.connection_handle = 0
		_popup.popup("@OTHER_PLAYER_LEFT", PopupDialog.Type.INFORMATION)
		#TODO: LET SERVER PEER WIN

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
		_popup.close()
		SteamUser.connection_handle = connection_handle
	
	# disconnected
	if new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY:
		print("CLIENT: disconnected, reconnecting...")
		
		_close_connection(connection_handle)
		
		if reconnect_loop < RECONNECT_MAX_TIME:
			reconnect_loop += 1
			_popup.popup("@RECONNECTING", PopupDialog.Type.PROGRESS)
			_reconnect_to_listen_socket()
		else:	
			print("CLIENT: reconnect failed.")
			_popup.popup("@RECONNECT_FAILED", PopupDialog.Type.INFORMATION)
			#TODO: LET SERVER WIN	
			pass

	# listening socket closed (owner of room left):
	if old_state == Steam.CONNECTION_STATE_CONNECTED and new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("CLIENT: connection closed, owner left.")
		_close_connection(connection_handle)
		_popup.popup("@OTHER_PLAYER_HAS_LEFT", PopupDialog.Type.INFORMATION)
		#TODO: LET CLIENT PEER WIN

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
