extends PanelContainer

const COLOR_EVENT := '#8ad1e6'
const COLOR_PLAYER := '#ffffff'

func _ready() -> void:
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_message.connect(_on_lobby_message)
	
	var message := "Room joined (ID: %s)" % SteamUser.lobby_id
	
	if SteamUser.STEAM_ID == Steam.getLobbyOwner(SteamUser.lobby_id):
		message = "Room created (ID: %s)" % SteamUser.lobby_id
		
	_display_message(message, COLOR_EVENT, false)

	%SendButton.pressed.connect(_send_message)
	%InputLine.text_submitted.connect(func(_new_text): _send_message())

func _send_message() -> void:
	var message: String = %InputLine.text.strip_edges()
	
	if message.length() > 0:
		print("SENDING MESSAGE")
		var sent := Steam.sendLobbyChatMsg(SteamUser.lobby_id, message)	
		
		if sent:
			%InputLine.clear()

func _on_lobby_chat_update(lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	var username: String = Steam.getFriendPersonaName(change_id)
	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		_display_message("%s %s" % [username, tr("@PLAYER_HAS_JOINED")], COLOR_EVENT)

	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		_display_message("%s %s" % [username, tr("@PLAYER_HAS_LEFT")], COLOR_EVENT)

	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		_display_message("%s %s" % [username, tr("@PLAYER_HAS_BEEN_KICKED")], COLOR_EVENT)

func _on_lobby_message(lobby_id: int, user: int, message: String, chat_type: int):
	#TODO: implement  this
#	if lobby_id != SteamUser.lobby_id:
#		return

	print("MESSAGE RECEIVED")
	var username := Steam.getFriendPersonaName(user)
	_display_message("%s: %s" % [username, message], COLOR_PLAYER)
	
	
func _display_message(message: String, color: String, new_line: bool = true):
	if new_line:
		%ChatLog.append_text('\n')
		
	%ChatLog.append_text("[color=%s]%s[/color]" % [color, message]) 
	
