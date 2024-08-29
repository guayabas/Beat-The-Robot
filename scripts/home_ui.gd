extends Control

class_name BeatTheRobotHomeUI

@export_group("Development")
@export var disable_godot_key_bindings : bool = false
@export var console_log_developer_mode : bool = false
@onready var joy_pad_d_pad_event_timer = $JoyPadDPadEventTimer
var joy_pad_axis_ready_for_event : bool = true

@export_group("UI Elements")
@export var start_game_button : Button
@export var settings_game_button : Button
@export var exit_game_button : Button
enum ButtonOnFocus { NONE = -1, START = 0, SETTINGS, EXIT }
enum CycleMenuDirection { DOWN, UP }
var current_button_on_focus = ButtonOnFocus.NONE

# NOTE : Notice that a signal can have multiple attachments that will be triggered
# for every callable once the .emit() is submitted. In this game there is base node
# called game that uses this signal (_on_home_ui_inform_game_that_user_has_started_game)
# to know when the game has started but also this signal (_on_inform_game_that_user_has_started_game)
# is used to debug the UI that represents this file
signal inform_game_that_user_has_started_game(event : InputEvent)
signal inform_game_that_settings_screen_are_displayed(event : InputEvent)
signal inform_game_that_user_has_exited_game(event : InputEvent)

var actions_to_preserve = \
[
	"player_move_left",
	"player_move_right",
	"player_move_up",
	"player_move_down"
]
var is_menu_settings_being_displayed : bool = false
var player_is_playing_a_level : bool = false

@onready var move_up_down_menu = $Sounds/MoveUpDownMenu

func update_focus(button_on_focus : ButtonOnFocus):
	current_button_on_focus = button_on_focus
	match button_on_focus:
		ButtonOnFocus.START:
			start_game_button.grab_focus()
		ButtonOnFocus.SETTINGS:
			settings_game_button.grab_focus()
		ButtonOnFocus.EXIT:
			exit_game_button.grab_focus()
		_:
			pass

func cycle_down_menu_options(button_on_focus : ButtonOnFocus):
	match button_on_focus:
		ButtonOnFocus.START:
			return ButtonOnFocus.SETTINGS
		ButtonOnFocus.SETTINGS:
			return ButtonOnFocus.EXIT
		ButtonOnFocus.EXIT:
			return ButtonOnFocus.START
		_:
			return -1

func cycle_up_menu_options(button_on_focus : ButtonOnFocus):
	match button_on_focus:
		ButtonOnFocus.START:
			return ButtonOnFocus.EXIT
		ButtonOnFocus.SETTINGS:
			return ButtonOnFocus.START
		ButtonOnFocus.EXIT:
			return ButtonOnFocus.SETTINGS
		_:
			return -1

func start_focus_on_start_button():
	update_focus(ButtonOnFocus.START)

func cycle_menu_option(button_on_focus : ButtonOnFocus, cycle_direction : CycleMenuDirection):
	var next_button_in_focus = -1
	if cycle_direction == CycleMenuDirection.DOWN:
		next_button_in_focus = cycle_down_menu_options(button_on_focus)
	else:
		next_button_in_focus = cycle_up_menu_options(button_on_focus)
	if next_button_in_focus != -1:
		update_focus(next_button_in_focus)
	move_up_down_menu.play()

func handle_joy_motion_with_sound_for_godot_action(action_name : String, event : InputEvent):
	if event.get_action_strength(action_name) > 0.5 and joy_pad_axis_ready_for_event:
		joy_pad_axis_ready_for_event = false
		move_up_down_menu.play()
		joy_pad_d_pad_event_timer.start()

func _ready():

	# NOTE : This is a way of disabling the default actions  provided
	# by Godot, it might not be safe specially if used with the @tool
	# annotation but for now leave it as it is
	if disable_godot_key_bindings:
		for action in InputMap.get_actions():
			if action not in actions_to_preserve:
				InputMap.action_erase_events(action)

	# NOTE : This is to make a signal connection via code, investigate if it is possible
	# to refresh the Godot editor to show the green arrow in a node with a signal
	# via this way similar to what one gets when using the Godot editor for adding a connection
	# for a signal
	exit_game_button.connect("mouse_entered", _on_exit_game_button_mouse_entered)
	exit_game_button.connect("pressed", _on_exit_game_button_pressed)
	start_focus_on_start_button()

func _unhandled_key_input(event : InputEvent):
	if disable_godot_key_bindings:
		if !player_is_playing_a_level and !is_menu_settings_being_displayed:
			if event is InputEventKey:
				if event.pressed and !event.shift_pressed:
					match event.keycode:
						KEY_DOWN:
							cycle_menu_option(current_button_on_focus, CycleMenuDirection.DOWN)
						KEY_UP:
							cycle_menu_option(current_button_on_focus, CycleMenuDirection.UP)
						KEY_ENTER:
							if current_button_on_focus == ButtonOnFocus.START:
								inform_game_that_user_has_started_game.emit(event)
							if current_button_on_focus == ButtonOnFocus.EXIT:
								inform_game_that_user_has_exited_game.emit(event)
							if current_button_on_focus == ButtonOnFocus.SETTINGS:
								inform_game_that_settings_screen_are_displayed.emit(event)

func _unhandled_input(event : InputEvent):
	if disable_godot_key_bindings:
		if !player_is_playing_a_level and !is_menu_settings_being_displayed:
			if event is InputEventJoypadButton:
				if event.pressed:
					match event.button_index:
						JOY_BUTTON_DPAD_DOWN:
							cycle_menu_option(current_button_on_focus, CycleMenuDirection.DOWN)
						JOY_BUTTON_DPAD_UP:
							cycle_menu_option(current_button_on_focus, CycleMenuDirection.UP)
						JOY_BUTTON_A:
							if current_button_on_focus == ButtonOnFocus.START:
								inform_game_that_user_has_started_game.emit(event)
							if current_button_on_focus == ButtonOnFocus.EXIT:
								inform_game_that_user_has_exited_game.emit(event)
							if current_button_on_focus == ButtonOnFocus.SETTINGS:
								inform_game_that_settings_screen_are_displayed.emit(event)
			if event is InputEventJoypadMotion:
				match event.axis:
					JOY_AXIS_LEFT_Y:
						if abs(event.axis_value) > 0.5:
							if joy_pad_axis_ready_for_event:
								joy_pad_axis_ready_for_event = false
								if event.axis_value > 0.0:
									cycle_menu_option(current_button_on_focus, CycleMenuDirection.DOWN)
								else:
									cycle_menu_option(current_button_on_focus, CycleMenuDirection.UP)
							else:
								joy_pad_d_pad_event_timer.start()

func _input(event : InputEvent):
	if self.visible:
		if !disable_godot_key_bindings:
			if event.is_action_pressed("ui_accept"):
				pass
			elif event.is_action_pressed("ui_down"):
				handle_joy_motion_with_sound_for_godot_action("ui_down", event)
			elif event.is_action_pressed("ui_up"):
				handle_joy_motion_with_sound_for_godot_action("ui_up", event)

func _on_joy_pad_d_pad_event_timer_timeout():
	joy_pad_axis_ready_for_event = true

func _on_start_game_button_pressed():
	inform_game_that_user_has_started_game.emit(InputEventMouseButton.new())

func _on_exit_game_button_pressed():
	inform_game_that_user_has_exited_game.emit(InputEventMouseButton.new())

func _on_settings_button_pressed():
	inform_game_that_settings_screen_are_displayed.emit(InputEventMouseButton.new())

func _on_exit_game_button_mouse_entered():
	update_focus(ButtonOnFocus.EXIT)

func _on_start_game_button_mouse_entered():
	update_focus(ButtonOnFocus.START)

func _on_settings_button_mouse_entered():
	update_focus(ButtonOnFocus.SETTINGS)

func _on_inform_game_that_user_has_started_game(event : InputEvent):
	if console_log_developer_mode:
		print("signal to start game has been called from ", event.as_text())

func _on_inform_game_that_settings_screen_are_displayed(event : InputEvent):
	if console_log_developer_mode:
		print("signal to show settings has been called from ", event.as_text())

func _on_inform_game_that_user_has_exited_game(event : InputEvent):
	if console_log_developer_mode:
		print("signal to exit game has been called from ", event.as_text())
