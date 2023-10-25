extends Node

const RECONNECT_MAX_TIME: int = 9
var reconnect_loop: int = 0

var _popup: PopupDialog

func _init() -> void:
	pass

func setup(popup: PopupDialog) -> void:
	pass

func _on_network_connection_status_changed_server(connection_handle: int, connection: Dictionary, old_state: int):
	pass

func _on_network_connection_status_changed_client(connection_handle: int, connection: Dictionary, old_state: int):
	pass

func _reconnect_to_listen_socket():
	pass

func _close_connection(connection_handle: int):
	pass
