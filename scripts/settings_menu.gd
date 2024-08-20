extends ColorRect

class_name BeatTheRobotSettingsMenu
@export var background_music_slider : Slider
@export var sound_effects_slider : Slider
@export var fullscreen_checkbox : CheckBox
@export var return_button : Button

signal inform_game_that_return_button_has_been_pressed(from_game_controller:bool)

func _ready():
	background_music_slider.connect("value_changed", _on_background_music_slider_value_changed)
	sound_effects_slider.connect("value_changed", _on_sound_effects_slider_value_changed)
	fullscreen_checkbox.connect("toggled", _on_fullscreen_checkbox_toggled)

func _on_background_music_slider_value_changed(value : float):
	if false:
		print(value, " ", linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background Music"), linear_to_db(value))

func _on_sound_effects_slider_value_changed(value : float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), linear_to_db(value))

func _on_fullscreen_checkbox_toggled(toggled_on : bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func _unhandled_input(event):
	if event is InputEventKey:
			if event.pressed and !event.echo and !event.shift_pressed:
				match event.keycode:
					Key.KEY_ESCAPE:
						inform_game_that_return_button_has_been_pressed.emit(false)
	if event is InputEventJoypadButton:
		if event.pressed:
			match event.button_index:
				JOY_BUTTON_START:
					inform_game_that_return_button_has_been_pressed.emit(true)
