extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Khung/PhanDau/TieuDe/Xuong/Money.text = "Xương : " + str(Data.money)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_nut_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")
