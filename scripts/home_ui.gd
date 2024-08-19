extends Control

class_name BeatTheRobotHomeUI

@export var start_game_button : Button
@export var settings_game_button : Button
@export var exit_game_button : Button
enum ButtonOnFocus { START, SETTINGS, EXIT }
enum CycleMenuDirection { DOWN, UP }
var current_button_on_focus : ButtonOnFocus = ButtonOnFocus.START
@onready var joy_pad_d_pad_event_timer = $JoyPadDPadEventTimer
var joy_pad_axis_ready_for_event : bool = true
var actions_to_preserve = \
[
	"player_move_left",
	"player_move_right",
	"player_move_up",
	"player_move_down"
]

signal inform_game_that_user_has_started_game
var player_is_playing_a_level : bool = false

func update_focus(button_on_focus : ButtonOnFocus):
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
	update_focus(current_button_on_focus)

func cycle_menu_option(button_on_focus : ButtonOnFocus, cycle_direction : CycleMenuDirection):
	var next_button_in_focus = -1
	if cycle_direction == CycleMenuDirection.DOWN:
		next_button_in_focus = cycle_down_menu_options(button_on_focus)
	else:
		next_button_in_focus = cycle_up_menu_options(button_on_focus)
	if next_button_in_focus != -1:
		current_button_on_focus = next_button_in_focus
		update_focus(current_button_on_focus)

func _ready():
	# NOTE : This is a way of disabling the default actions  provided
	# by Godot, it might not be safe specially if used with the @tool
	# annotation but for now leave it as it is
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

func _process(_delta):
	pass
	
func _unhandled_key_input(event):
	if !player_is_playing_a_level:
		if event is InputEventKey:
			if event.pressed and !event.shift_pressed:
				match event.keycode:
					KEY_DOWN:
						cycle_menu_option(current_button_on_focus, CycleMenuDirection.DOWN)
					KEY_UP:
						cycle_menu_option(current_button_on_focus, CycleMenuDirection.UP)
					KEY_ENTER:
						if current_button_on_focus == ButtonOnFocus.START:
							inform_game_that_user_has_started_game.emit()
						if current_button_on_focus == ButtonOnFocus.EXIT:
							get_tree().quit()

func _unhandled_input(event):
	if !player_is_playing_a_level:
		if event is InputEventJoypadButton:
			if event.pressed:
				match event.button_index:
					JOY_BUTTON_DPAD_DOWN:
						cycle_menu_option(current_button_on_focus, CycleMenuDirection.DOWN)
					JOY_BUTTON_DPAD_UP:
						cycle_menu_option(current_button_on_focus, CycleMenuDirection.UP)
					JOY_BUTTON_A:
						if current_button_on_focus == ButtonOnFocus.START:
							inform_game_that_user_has_started_game.emit()
						if current_button_on_focus == ButtonOnFocus.EXIT:
							get_tree().quit()
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

func _on_joy_pad_d_pad_event_timer_timeout():
	joy_pad_axis_ready_for_event = true

func _on_start_game_button_pressed():
	inform_game_that_user_has_started_game.emit()

func _on_exit_game_button_pressed():
	get_tree().quit()

func _on_exit_game_button_mouse_entered():
	exit_game_button.grab_focus()

func _on_start_game_button_mouse_entered():
	start_game_button.grab_focus()

func _on_settings_button_mouse_entered():
	settings_game_button.grab_focus()

func _on_mouse_entered():
	pass
