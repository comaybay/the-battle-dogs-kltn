extends Control
# Called when the node enters the scene tree for the first time.
func _ready():	

	pass # Replace with function body.


func _on_nut_bat_dau_pressed():
	$NhanNut.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")


func _on_nut_thoat_pressed():
	$NhanNut.play()
	await get_tree().create_timer(0.5).timeout
	


func _on_nut_huong_dan_pressed():
	$NhanNut.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/instruction/instruction.tscn")
