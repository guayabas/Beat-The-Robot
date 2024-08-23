extends VBoxContainer

class_name LevelSelectionContainerButton

@onready var texture_button = $TextureButton
@onready var label = $Label

var button_id : int = -1

func set_id(id_to_set_for_button : int):
	button_id = id_to_set_for_button
