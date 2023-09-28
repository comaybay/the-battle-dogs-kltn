extends OptionButton
const LANGUAGES := ["vi", "en"]

func _ready() -> void:
	add_item("Tiếng Việt")
	add_item("English")
	
	select(LANGUAGES.find(Data.game_language))

	item_selected.connect(func (index: int) -> void:
		AudioPlayer.play_button_pressed_audio()
		TranslationServer.set_locale(LANGUAGES[index])	
		
		Data.game_language = LANGUAGES[index]
		Data.save()
	)
