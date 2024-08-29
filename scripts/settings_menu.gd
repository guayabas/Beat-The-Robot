extends ColorRect

class_name BeatTheRobotSettingsMenu

@export_group("Development")
@export var console_log_developer_mode = false

@export_group("UI Elements")
@export var background_music_slider : Slider
@export var sound_effects_slider : Slider
@export var fullscreen_checkbox : CheckBox
@export var return_button : Button
@onready var color_rect = $ColorRect

signal inform_game_that_return_button_has_been_pressed(from_game_controller : bool)

func console_log_elements_and_focus_in_linear_time():
	var nodes = get_tree_string().split('\n')
	print()
	for node_name in nodes.slice(0, nodes.size() - 1):
		var node = get_node(node_name)
		if node is Control:
			print(node.has_focus(), "\t", node)
	print()

func _init():
	var timer_console_log_out = Timer.new()
	timer_console_log_out.wait_time = 1.0
	timer_console_log_out.autostart = false
	timer_console_log_out.connect("timeout", _on_timeout_timer_console_log_out)
	self.add_child(timer_console_log_out)

func _ready():
	background_music_slider.connect("value_changed", _on_background_music_slider_value_changed)
	sound_effects_slider.connect("value_changed", _on_sound_effects_slider_value_changed)
	fullscreen_checkbox.connect("toggled", _on_fullscreen_checkbox_toggled)

func _process(_delta):
	pass

func _unhandled_input(event):
	if event is InputEventKey:
			if event.pressed and !event.echo and !event.shift_pressed:
				match event.keycode:
					Key.KEY_ESCAPE:
						inform_game_that_return_button_has_been_pressed.emit(false)
					Key.KEY_ENTER:
						if return_button.has_focus():
							inform_game_that_return_button_has_been_pressed.emit(false)
	if event is InputEventJoypadButton:
		if event.pressed:
			match event.button_index:
				JOY_BUTTON_START:
					inform_game_that_return_button_has_been_pressed.emit(true)
				JOY_BUTTON_B:
					inform_game_that_return_button_has_been_pressed.emit(false)
				JOY_BUTTON_A:
					# TODO : The signal inform_game_that_return_button_has_been_pressed()
					# with the boolean argument to check if it comes from the keyboard
					# or the game controller is not relevant anymore in this call ...
					if return_button.has_focus():
						inform_game_that_return_button_has_been_pressed.emit(false)
					pass

func _on_timeout_timer_console_log_out():
	if console_log_developer_mode:
		console_log_elements_and_focus_in_linear_time()

func _on_background_music_slider_value_changed(value : float):
	if console_log_developer_mode:
		print("background music volume ", value, " ", linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background Music"), linear_to_db(value))

func _on_sound_effects_slider_value_changed(value : float):
	if console_log_developer_mode:
		print("sound effects volume ", value, " ", linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), linear_to_db(value))

func _on_fullscreen_checkbox_toggled(toggled_on : bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		var window_dimensions = Vector2i(512 * 1.5, 512 * 1.5)
		var screen_size = DisplayServer.screen_get_size(0)
		# NOTE : Check the documentation for DisplayServer to understand
		# why the usage of DisplayServer.screen_get_position()
		var top_left_corner = DisplayServer.screen_get_position(0) + (screen_size - window_dimensions) / 2
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(window_dimensions)
		DisplayServer.window_set_position(top_left_corner)
		DisplayServer.window_set_title("")

func _on_background_music_slider_drag_ended(_value_changed):
	#background_music_slider.release_focus()
	pass

func _on_sound_effects_slider_drag_ended(_value_changed):
	#sound_effects_slider.release_focus()
	pass

func _on_fullscreen_checkbox_mouse_entered():
	fullscreen_checkbox.grab_focus()

func _on_fullscreen_checkbox_mouse_exited():
	#fullscreen_checkbox.release_focus()
	pass

func _on_return_button_pressed():
	inform_game_that_return_button_has_been_pressed.emit(false)

func _on_return_button_mouse_entered():
	return_button.grab_focus()

func _on_return_button_mouse_exited():
	#return_button.release_focus()
	pass

func _on_inform_game_that_return_button_has_been_pressed(from_game_controller : bool):
	if console_log_developer_mode:
		print("return button has been pressed using game controller ", from_game_controller)
