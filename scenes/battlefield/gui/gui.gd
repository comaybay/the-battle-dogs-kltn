extends Control

var CharacterButtonScene: PackedScene = preload("res://scenes/battlefield/gui/character_button/character_button.tscn")

func _ready() -> void:
	for name_id in Data.selected_team['dog_name_ids']:
		var character_button: CharacterButton = CharacterButtonScene.instantiate()	
		character_button.init(name_id, 0.2)
		$HFlowContainer.add_child(character_button)
	
