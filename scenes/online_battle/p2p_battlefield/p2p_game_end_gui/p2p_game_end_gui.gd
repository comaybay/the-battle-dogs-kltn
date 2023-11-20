class_name P2PGameEndGUI extends CanvasLayer

var DEFEAT_AUDIO: AudioStream = preload("res://resources/sound/battlefield/defeat.mp3")
var VICTORY_AUDIO: AudioStream = preload("res://resources/sound/battlefield/victory.mp3")

func setup(winner_id: int) -> void:	
	AudioPlayer.stop_current_music(true, true)
	AudioPlayer.play_music(VICTORY_AUDIO if winner_id == SteamUser.STEAM_ID else DEFEAT_AUDIO)
	
	var this_player_is_winner := winner_id == SteamUser.STEAM_ID
	_setup_victory_status_text(%GameResultLabel, this_player_is_winner)
	
	%Player1Name.text = SteamUser.players[0]['username']
	%Player2Name.text = SteamUser.players[1]['username']
	
	if winner_id == SteamUser.players[0]['steam_id']:
		_setup_victory_status_text(%Player1Status, true)
		_setup_victory_status_text(%Player2Status, false)
	else:
		_setup_victory_status_text(%Player1Status, false)
		_setup_victory_status_text(%Player2Status, true)
	
	%ToRoomButton.pressed.connect(_go_to_room)
	$AnimationPlayer.play("start")
	
func _setup_victory_status_text(label: Label, is_winner: bool):
	label.text = tr("@VICTORY" if is_winner else "@DEFEAT")
	label.add_theme_color_override("font_outline_color",
		0x008bc7ff if is_winner else 0xad1c00ff
	)
	
func _go_to_room():
	AudioPlayer.play_sfx(AudioPlayer.BUTTON_PRESSED_AUDIO)
	get_tree().change_scene_to_file("res://scenes/online_battle/lobby/room/room.tscn")
