extends Button

var existing_texture = get_theme_stylebox("normal")

func _ready():
	existing_texture = get_theme_stylebox("normal")
	# Tạo một StyleBoxTexture mới với tệp hình ảnh của bạn
	var custom_texture = StyleBoxTexture.new()
	custom_texture.texture = load("res://resources/images/Screenshot (5).png")
	custom_texture.expand_margin_bottom = 5	
	add_theme_stylebox_override("normal",custom_texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	var existing_texture = get_theme_stylebox("normal")
	# Tạo một StyleBoxTexture mới với tệp hình ảnh của bạn
	var custom_texture = StyleBoxFlat.new()	
	custom_texture.expand_margin_bottom = 5	
	add_theme_stylebox_override("normal",custom_texture)
