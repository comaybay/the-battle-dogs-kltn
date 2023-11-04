extends Node

var _popup: PopupDialog

func _init() -> void:
	var is_owner: bool = SteamUser.is_lobby_owner()
	
	if is_owner:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_server)
	else:
		Steam.network_connection_status_changed.connect(_on_network_connection_status_changed_client)

func setup(popup: PopupDialog) -> void:
	$ReconnectTimer.timeout.connect(_on_reconnect_timeout)
	_popup = popup

func _on_network_connection_status_changed_server(connection_handle: int, connection: Dictionary, old_state: int):
	var new_state: int = connection['connection_state']
	# example: steamid:76561199486434807" -> 76561199486434807
	var steam_id: int = int(connection['identity'].get_slice(":", 1))
	var username: String = Steam.getFriendPersonaName(steam_id)
	print("old_state-------")
	print(old_state)
	print(connection)
	print("old_state-------")
	
	# opponent trying to reconnect, accept connection
	var is_player_in_battle = SteamUser.players.filter(
		func(player): return player['steam_id'] == steam_id
	).size() > 0
	
	if (
		new_state == Steam.CONNECTION_STATE_CONNECTING
		and is_player_in_battle 
	):
		get_tree().paused = false
		print("SERVER: ACCEPT CONNECTION %s" % connection_handle)
		Steam.acceptConnection(connection_handle)
		SteamUser.connection_handle = connection_handle
		$ReconnectTimer.stop()
		_popup.close()
		return
	
	var old_state_equals_connecting: bool = (
		old_state == Steam.CONNECTION_STATE_CONNECTING 
		or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE
	)
	
	if old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_CONNECTED:
		print("SERVER: connection re-established.")
		return
		
	# failed to connect
	if new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY:
		print("SERVER: failed to connect with peer")
		_close_connection(connection_handle)

		if $ReconnectTimer.is_stopped():
			get_tree().paused = true
			$ReconnectTimer.start()
			
			_popup.popup_process(
				func(): return "%s %s... (%s)" % [
					tr("@RECONNECTING_WITH"), username, int($ReconnectTimer.time_left)
				],
				PopupDialog.Type.PROGRESS
			)

	if new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:
		print("SERVER: connection closed by peer")
		_close_connection(connection_handle)
		_popup.popup("@OTHER_PLAYER_LEFT", PopupDialog.Type.INFORMATION)
		await _popup.ok
		(InBattle.get_battlefield() as P2PBattlefield).end_game(SteamUser.STEAM_ID)
		
func _on_reconnect_timeout():
	var is_server: = SteamUser.is_lobby_owner()

	if is_server:
		SteamUser.set_lobby_data("game_status", "waiting")
		Steam.network_connection_status_changed.disconnect(_on_network_connection_status_changed_server)
		Steam.closeListenSocket(SteamUser.listen_socket)
		SteamUser.listen_socket = 0
		_popup.popup("@OTHER_PLAYER_LEFT", PopupDialog.Type.INFORMATION)
		await _popup.ok
		(InBattle.get_battlefield() as P2PBattlefield).end_game(SteamUser.STEAM_ID)
	else:
		Steam.network_connection_status_changed.disconnect(_on_network_connection_status_changed_client)
		_popup.popup("@RECONNECT_FAILED", PopupDialog.Type.INFORMATION)
		await _popup.ok
		Steam.leaveLobby(SteamUser.lobby_id)
		SteamUser.lobby_id = 0
		var opponent_id = InBattle.get_opponent_data().get_steam_id()
		(InBattle.get_battlefield() as P2PBattlefield).end_game(opponent_id)

func _on_network_connection_status_changed_client(connection_handle: int, connection: Dictionary, old_state: int):
	print("==========")
	print(connection)
	print("==========")
	var new_state: int = connection['connection_state']
	
	var old_state_equals_connecting: bool = (
		old_state == Steam.CONNECTION_STATE_CONNECTING 
		or old_state == Steam.CONNECTION_STATE_FINDING_ROUTE
	)
	
	# connection accepted
	if old_state_equals_connecting and new_state == Steam.CONNECTION_STATE_CONNECTED:
		print("CLIENT: connection re-established.")
		_handle_connection_reestablished(connection_handle)
		return
	
	## server close connection
	if new_state == Steam.CONNECTION_STATE_CLOSED_BY_PEER:			
		_handle_server_close_connection(connection_handle)
		return 
			
	# disconnected
	if (
		new_state == Steam.CONNECTION_STATE_PROBLEM_DETECTED_LOCALLY 
	):
		print("CLIENT: disconnected, reconnecting...")
		
		_close_connection(connection_handle)
		_reconnect_to_listen_socket()
		
		# show reconnecting message
		if $ReconnectTimer.is_stopped():
			get_tree().paused = true
			$ReconnectTimer.start()
			_popup.popup_process(func():
				return "%s (%s)" % [tr("@RECONNECTING"), int($ReconnectTimer.time_left)]
			, PopupDialog.Type.PROGRESS)

func _handle_connection_reestablished(connection_handle: int) -> void:
	get_tree().paused = false
	$ReconnectTimer.stop()
	_popup.close()
	SteamUser.connection_handle = connection_handle
	
	## rejoin lobby
	Steam.joinLobby(SteamUser.lobby_id)
	Steam.lobby_joined.connect(_on_lobby_rejoined, CONNECT_ONE_SHOT)

func _on_lobby_rejoined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# check if game has ended
		var winner := SteamUser.get_lobby_data("winner")
		print(winner)
		if winner != "":
			(InBattle.get_battlefield() as P2PBattlefield).end_game(int(winner))
	else:
		SteamUser.lobby_id = 0
		_close_connection(SteamUser.connection_handle)
		_popup.popup("@GAME_LOST_CONNECTION", PopupDialog.Type.INFORMATION)	
		await _popup.ok	
		get_tree().change_scene_to_file("res://scenes/online_battle/lobby/lobby.tscn")
		
func _handle_server_close_connection(connection_handle: int) -> void:
	print("CLIENT: connection closed, owner left.")
	_close_connection(connection_handle)
	_popup.popup("@OTHER_PLAYER_HAS_LEFT", PopupDialog.Type.INFORMATION)
	await _popup.ok
	(InBattle.get_battlefield() as P2PBattlefield).end_game(SteamUser.STEAM_ID)
	return

## returns connection_handler
func _reconnect_to_listen_socket() -> void:
	var server_id: int = SteamUser.players[0]['steam_id']
	print("CONNECTING TO LISTEN SOCKET of lobby: %s, owner: %s" % [SteamUser.lobby_id, server_id])
	Steam.clearIdentity("room_owner")
	Steam.addIdentity("room_owner")
	Steam.setIdentitySteamID64("room_owner", server_id)
	Steam.connectP2P("room_owner", 0, [])	
		
func _close_connection(connection_handle: int) -> void:
	Steam.closeConnection(connection_handle, Steam.CONNECTION_END_REMOTE_TIMEOUT, "CLOSE CONNECTION", false)
	Steam.clearIdentity("room_owner")
	print("CLOSE CONNECTION: " + str(connection_handle))
	SteamUser.connection_handle = 0

func _start_timer():
	get_tree().paused = true
