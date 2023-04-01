extends Control 


@export var level_now = 3
func _ready():
	pass

func _draw():
	var allMap = $Khung/map/AllLevel.get_children()	
	for level in level_now-1:
		print(level)
		var line = Line2D.new()
		line.default_color = Color(1, 1, 1)
		line.width = 5
		var vitri1 = allMap[level].position + Vector2(20,20)
		var vitri2 = allMap[level+1].position+ Vector2(20,20)
		line.set_points([vitri1, vitri2])
		add_child(line)

func _process(delta):	
	pass
	
func _on_nut_tan_cong_pressed():
	pass

	
func _on_doi_doi_hinh_pressed():
	get_tree().change_scene_to_file("res://scenes/map/map2.tscn")

func _on_quay_lai_pressed():
	get_tree().change_scene_to_file("res://scenes/dogBase/dogBase.tscn")



func _on_level_pressed():
	pass # Replace with function body.
