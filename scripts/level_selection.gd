extends Control

signal inform_game_that_level_has_been_selected_from_ui(selected_level_id : int)

@export var level_selection_container_button_1 : LevelSelectionContainerButton
@export var level_selection_container_button_2 : LevelSelectionContainerButton
@export var level_selection_container_button_3 : LevelSelectionContainerButton
@export var level_selection_container_button_4 : LevelSelectionContainerButton
@export var level_selection_container_button_5 : LevelSelectionContainerButton
@export var level_selection_container_button_6 : LevelSelectionContainerButton
@export var level_selection_container_button_7 : LevelSelectionContainerButton
@export var level_selection_container_button_8 : LevelSelectionContainerButton
@export var level_selection_container_button_9 : LevelSelectionContainerButton

var current_level_selected : int = -1

func set_level_container_info(object : LevelSelectionContainerButton, level_id : int, signal_callable : Callable):
	object.set_id(level_id)
	object.texture_button.connect("button_down", signal_callable)
	object.label.text = "Level " + str(level_id)
	pass

func get_id_with_focus():
	if level_selection_container_button_1.texture_button.has_focus():
		return level_selection_container_button_1.button_id
	elif level_selection_container_button_2.texture_button.has_focus():
		return level_selection_container_button_2.button_id
	elif level_selection_container_button_3.texture_button.has_focus():
		return level_selection_container_button_3.button_id
	elif level_selection_container_button_4.texture_button.has_focus():
		return level_selection_container_button_4.button_id
	elif level_selection_container_button_5.texture_button.has_focus():
		return level_selection_container_button_5.button_id
	elif level_selection_container_button_6.texture_button.has_focus():
		return level_selection_container_button_6.button_id
	elif level_selection_container_button_7.texture_button.has_focus():
		return level_selection_container_button_7.button_id
	elif level_selection_container_button_8.texture_button.has_focus():
		return level_selection_container_button_8.button_id
	elif level_selection_container_button_9.texture_button.has_focus():
		return level_selection_container_button_9.button_id
	else:
		return -1

func grab_focus_on_first_element():
	level_selection_container_button_1.texture_button.grab_focus()

func _ready():
	# NOTE : Sorry for the confusion of having some button numbers not consistent with the ID
	# assigned (for example level_selection_container_button_2 with ID 4). This is because the
	# layout created initially was for row alignment but for experience is better to have the levels
	# organized in a column-fashion way
	set_level_container_info(level_selection_container_button_1, 1, on_mouse_button_down_button_1)
	set_level_container_info(level_selection_container_button_2, 4, on_mouse_button_down_button_2)
	set_level_container_info(level_selection_container_button_3, 7, on_mouse_button_down_button_3)
	set_level_container_info(level_selection_container_button_4, 2, on_mouse_button_down_button_4)
	set_level_container_info(level_selection_container_button_5, 5, on_mouse_button_down_button_5)
	set_level_container_info(level_selection_container_button_6, 8, on_mouse_button_down_button_6)
	set_level_container_info(level_selection_container_button_7, 3, on_mouse_button_down_button_7)
	set_level_container_info(level_selection_container_button_8, 6, on_mouse_button_down_button_8)
	set_level_container_info(level_selection_container_button_9, 9, on_mouse_button_down_button_9)
	grab_focus_on_first_element()

func _process(_delta):
	pass
	
func _unhandled_key_input(event):
		if event is InputEventKey:
			if event.pressed:
				if event.keycode == KEY_ENTER:
					pass

func on_mouse_button_down_button_1():
	current_level_selected = level_selection_container_button_1.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_2():
	current_level_selected = level_selection_container_button_2.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_3():
	current_level_selected = level_selection_container_button_3.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_4():
	current_level_selected = level_selection_container_button_4.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_5():
	current_level_selected = level_selection_container_button_5.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_6():
	current_level_selected = level_selection_container_button_6.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_7():
	current_level_selected = level_selection_container_button_7.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_8():
	current_level_selected = level_selection_container_button_8.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)

func on_mouse_button_down_button_9():
	current_level_selected = level_selection_container_button_9.button_id
	inform_game_that_level_has_been_selected_from_ui.emit(current_level_selected)
