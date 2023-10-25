extends Node
## empty class (for p2p version with steam, but no steam is needed rn)	

var IS_USING_STEAM: bool = false

enum SendType {
	UNRELIABLE = 0, NO_NAGLE = 1, NO_DELAY = 4, RELIABLE = 8, 
}

func update_lobby_members():
	pass
	
func send_message(packet_data, send_type: SteamUser.SendType) -> void:
	pass
	
func read_messages():
	pass

func get_lobby_data(key: String) -> String:
	return ""

func set_lobby_data(key: String, value: String) -> void:
	pass

func get_member_data(member_id: int, key: String) -> String:
	return ""
	
func get_lobby_owner() -> int:
	return 0
