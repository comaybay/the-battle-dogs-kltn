extends Node

var screens 
var count = 0
var start = 0
var end = 3
func _ready():
	screens = $Node.get_children()
	
	if count == 0 :
		$BackForward.disabled = true
		
func _on_move_forward_pressed():
	AudioPlayer.play_button_pressed_audio()
	count += 1
	print(screens[count])
	screens[count-1].visible = false
	screens[count].visible = true
	$BackForward.disabled = false
	if count == end :
		
		$MoveForward.disabled = true


func _on_back_forward_pressed():
	AudioPlayer.play_button_pressed_audio()
	count -= 1
	screens[count+1].visible = false
	screens[count].visible = true
	$MoveForward.disabled = false
	$BackForward.disabled = false
	if count == start :
		$BackForward.disabled = true
	


func _on_go_back_button_pressed():
	AudioPlayer.play_button_pressed_audio()
	get_tree().change_scene_to_file("res://scenes/start_menu/main.tscn")
	pass # Replace with function body.