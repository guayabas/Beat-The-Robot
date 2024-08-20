extends Node2D

class_name BeatTheRobotGame

enum CameraMode { NONE, CANVAS, CENTER, FREE }

@export_group("Game")
@export var enable_dynamic_drawing : bool = false
@export var hide_mouse_cursor : bool = false
@export var visual_debug_mode : bool = true
@export var show_world_grid : bool = true
@export_subgroup("Grid Properties")
@export var grid_size : int = 32
@export var grid_thickness : float = 2.0
@onready var settings_menu = $CanvasLayer/SettingsMenu
@export_subgroup("Camera")
@export var camera_node : Camera2D
@export var camera_mode_in_use : CameraMode = CameraMode.NONE
@export var enable_dynamic_camera_adjustment : bool = true

@export_group("Player")
@export var player_node : CharacterBody2D

@export_group("Robot NPC")
@export var robot_node : BeatTheRobotRobot
@export var robot_path : Path2D
@onready var robot_path_following = $Levels/RobotPath/RobotPathFollowing
@onready var start_delay_timer = $Levels/StartDelayTimer
var start_delay_timer_out : bool = false

@export_group("Level")
@onready var start_level_screen = $CanvasLayer/StartLevelScreen
@onready var goal_area = $Levels/GoalArea
var level_has_started : bool = false
var player_has_started_game_from_main_menu : bool = false
signal inform_player_level_has_started
signal inform_player_level_has_finished

enum Scenes { HOME, LEVEL01, LEVEL02, CREDITS }
var current_scene : Scenes = Scenes.HOME
var current_scene_background_music : AudioStreamPlayer
@onready var level_01_tile_map = $Levels/Level01/Level01TileMap
@onready var level_01_robot_path = $Levels/Level01/Level01RobotPath
@onready var level_01_background_music = $Levels/Level01/Level01BackgroundMusic
@onready var level_02_tile_map = $Levels/Level02/Level02TileMap
@onready var level_02_robot_path = $Levels/Level02/Level02RobotPath
@onready var level_02_background_music = $Levels/Level02/Level02BackgroundMusic
@onready var credits_background_music = $Levels/Credits/CreditsBackgroundMusic
@onready var home_ui = $CanvasLayer/HomeUI
@onready var home_ui_background_music = $CanvasLayer/HomeUI/HomeUIBackgroundMusic

@onready var enter_settings_menu_sound = $CanvasLayer/SettingsMenu/EnterSettingsMenuSound
@onready var exit_settings_menu_sound = $CanvasLayer/SettingsMenu/ExitSettingsMenuSound

var initial_viewport_width : int = -1
var initial_viewport_height : int = -1
var initial_viewport_stretch_mode : String = ""
var last_window_mode_state : DisplayServer.WindowMode

func toggle_fullscreen() -> void:
	# TODO : There is a bug when the window goes from maximized
	# to fullscreen and then back to maximized to then moved within the
	# display that causes the returning window to be borderless, missin the native
	# icons to move the window in the OS display space
	var mode : DisplayServer.WindowMode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		settings_menu.fullscreen_checkbox.toggled.emit(false)
		settings_menu.fullscreen_checkbox.button_pressed = false
	else:
		settings_menu.fullscreen_checkbox.toggled.emit(true)
		settings_menu.fullscreen_checkbox.button_pressed = true

func disable_all_levels():
	level_01_robot_path.visible = false
	level_01_tile_map.set_layer_enabled(0, false)
	level_02_robot_path.visible = false
	level_02_tile_map.set_layer_enabled(0, false)

func enable_level(robot_path_to_enable : Path2D, tile_map_to_enable : TileMap):
	robot_path_to_enable.visible = true
	tile_map_to_enable.set_layer_enabled(0, true)

func is_scene_home_scene(scene : Scenes):
	if scene == Scenes.HOME:
		home_ui.visible = true
		player_node.visible = false
		goal_area.visible = false
		robot_node.visible = false
	else:
		home_ui.visible = false
		player_node.visible = true
		goal_area.visible = true
		robot_node.visible = true

func reset_scene(scene : Scenes):
	inform_player_level_has_finished.emit()
	level_has_started = false
	is_scene_home_scene(scene)
	match scene:
		Scenes.HOME:
			player_node.set_position(Vector2.ZERO)
			goal_area.set_position(Vector2(1024, 1024))
			disable_all_levels()
			start_level_screen.visible = false
		Scenes.LEVEL01:
			player_node.set_position(Vector2(96, 160))
			start_level_screen.update_level_label("Level : 01")
			robot_path.curve = level_01_robot_path.curve
			goal_area.set_position(robot_path.curve.get_point_position(robot_path.curve.point_count - 1))
			disable_all_levels()
			enable_level(level_01_robot_path, level_01_tile_map)
			start_level_screen.visible = true
			start_delay_timer_out = false
			robot_path_following.progress = 0
		Scenes.LEVEL02:
			player_node.set_position(Vector2(96, 96))
			start_level_screen.update_level_label("Level : 02")
			robot_path.curve = level_02_robot_path.curve
			goal_area.set_position(robot_path.curve.get_point_position(robot_path.curve.point_count - 1))
			disable_all_levels()
			enable_level(level_02_robot_path, level_02_tile_map)
			start_level_screen.visible = true
			start_delay_timer_out = false
			robot_path_following.progress = 0
		Scenes.CREDITS:
			goal_area.set_position(Vector2(512, 512))
			player_node.set_position(Vector2(512 - 128, 512))
			var simple_curve = Curve2D.new()
			simple_curve.add_point(Vector2(512 + 128, 512 - 8))
			simple_curve.add_point(Vector2(512 + 128, 512 + 8))
			robot_path.curve = simple_curve
			disable_all_levels()
			start_level_screen.visible = false
			start_delay_timer_out = true
			robot_path_following.progress_ratio = 0.5
		_:
			pass

func start_level():
	if !level_has_started and !player_node.is_menu_settings_being_displayed:
		level_has_started = true
		start_level_screen.visible = false
		inform_player_level_has_started.emit()
		start_delay_timer.start()

func next_scene(scene : Scenes):
	current_scene_background_music.stop()
	match scene:
		Scenes.HOME:
			current_scene_background_music = level_01_background_music
			return Scenes.LEVEL01
		Scenes.LEVEL01:
			current_scene_background_music = level_02_background_music
			return Scenes.LEVEL02
		_:
			current_scene_background_music = credits_background_music
			return Scenes.CREDITS

func cycle_scenes():
	if current_scene == Scenes.HOME:
		current_scene_background_music = level_01_background_music
		current_scene = Scenes.LEVEL01
		home_ui.player_is_playing_a_level = true
	elif current_scene == Scenes.LEVEL01:
		current_scene_background_music = level_02_background_music
		current_scene = Scenes.LEVEL02
		home_ui.player_is_playing_a_level = true
	elif current_scene == Scenes.LEVEL02:
		current_scene_background_music = credits_background_music
		current_scene = Scenes.CREDITS
		home_ui.player_is_playing_a_level = true
	elif current_scene == Scenes.CREDITS:
		current_scene_background_music = home_ui_background_music
		current_scene = Scenes.HOME
		home_ui.player_is_playing_a_level = false
		home_ui.start_focus_on_start_button()

func do_camera_adjustment(camera_mode_to_use : CameraMode):
	var current_viewport_size = get_viewport_rect().size
	match camera_mode_to_use:
		CameraMode.CANVAS:
			var camera_zoom_factor_x = float(current_viewport_size.x) / float(initial_viewport_width)
			var camera_zoom_factor_y = float(current_viewport_size.y) / float(initial_viewport_height)
			camera_node.zoom = Vector2(camera_zoom_factor_x, camera_zoom_factor_y)
			camera_node.position = Vector2.ZERO
			pass
		CameraMode.CENTER:
			var offset_x = (current_viewport_size.x - initial_viewport_width) * 0.5
			var offset_y = (current_viewport_size.y - initial_viewport_height) * 0.5
			camera_node.position = Vector2(-offset_x, -offset_y)
			camera_node.zoom = Vector2.ONE
			pass
		CameraMode.NONE:
			camera_node.position = Vector2.ZERO
			camera_node.zoom = Vector2.ONE
		CameraMode.FREE, _:
			pass

func _init():
	# NOTE : Hack to bring the window to foreground in the OS when the game
	# launches automatically in fullscreen mode. Maybe grab the current mode directly
	# from the editor when doing the development?
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		var script = "C:/Users/aleja/Desktop/BeatTheRobot/scripts/powershell_focus_game_window.ps1 "
		var arguments = "-windowTitle 'Godot_v4.2.2-stable_mono_win64' -processId " + str(OS.get_process_id())
		var command = (script + arguments)
		print(command)
		var output = []
		OS.execute("powershell.exe", ["-Command", command], output, false, false)
	pass

func _ready():
	initial_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	initial_viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	initial_viewport_stretch_mode = ProjectSettings.get_setting("display/window/stretch/mode")
	if hide_mouse_cursor:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().debug_collisions_hint = visual_debug_mode
	get_tree().debug_navigation_hint = visual_debug_mode
	get_tree().debug_paths_hint = visual_debug_mode
	reset_scene(current_scene)
	current_scene_background_music = home_ui_background_music
	current_scene_background_music.volume_db = linear_to_db(0.5)
	current_scene_background_music.play()
	settings_menu.visible = false
	settings_menu.background_music_slider.value = 0.5
	settings_menu.sound_effects_slider.value = 0.5
	pass

func _process(delta):
	if level_has_started \
	and start_delay_timer_out \
	and current_scene != Scenes.CREDITS \
	and !robot_node.is_ray_cast_colliding() \
	and !robot_node.is_menu_settings_being_displayed:
		robot_path_following.progress += ((64 * 4) * delta)
	if enable_dynamic_drawing:
		self.queue_redraw()
	if enable_dynamic_camera_adjustment and initial_viewport_stretch_mode == "disabled":
		do_camera_adjustment(camera_mode_in_use)
	pass

func _notification(what):
	if what == NOTIFICATION_DRAW:
		if show_world_grid:
			draw_grid()
	pass

func _physics_process(_delta):
	pass

func _input(_event):
	pass

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.shift_pressed:
			if event.pressed:
				if event.keycode == Key.KEY_ENTER:
					toggle_fullscreen()
		else:
			if event.pressed and !event.echo:
				match event.keycode:
					Key.KEY_R:
						reset_scene(current_scene)
					Key.KEY_I:
						robot_path_following.progress_ratio = 0.0
					Key.KEY_D:
						if !enable_dynamic_drawing:
							self.queue_redraw()
					Key.KEY_P:
						camera_node.position = Vector2.ZERO
						camera_node.zoom = Vector2.ONE
					Key.KEY_Q:
						get_tree().quit()
					KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN:
						start_level()
					KEY_ESCAPE:
						pass
					KEY_TAB:
						current_scene_background_music.stop()
						cycle_scenes()
						reset_scene(current_scene)
						current_scene_background_music.play()

func _unhandled_input(event):
	#print(event)
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.5:
			start_level()
	elif event is InputEventJoypadButton:
		if event.pressed:
			match event.button_index:
				JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_UP:
					start_level()
	elif event is InputEventMouseButton:
		if initial_viewport_stretch_mode == "disabled":
			match event.button_index:
				MOUSE_BUTTON_WHEEL_DOWN:
					camera_node.zoom += Vector2(0.1, 0.1)
					pass
				MOUSE_BUTTON_WHEEL_UP:
					camera_node.zoom -= Vector2(0.1, 0.1)
					pass
	elif event is InputEventMouseMotion:
		if initial_viewport_stretch_mode == "disabled":
			match event.button_mask:
				MOUSE_BUTTON_LEFT:
					camera_node.position.x -= event.relative.x
					camera_node.position.y -= event.relative.y

func _on_area_2d_body_entered(body):
	if current_scene != Scenes.CREDITS:
		if body.name == "Player":
			print("you won at level : ", current_scene)
			current_scene = next_scene(current_scene)
			current_scene_background_music.play()
		elif body.name == "Robot":
			print("you lost at level : ", current_scene)
		reset_scene(current_scene)
	pass

func _on_inform_player_level_has_started():
	player_node.level_has_started = true

func _on_inform_player_level_has_finished():
	player_node.level_has_started = false

func _on_start_delay_timeout():
	start_delay_timer_out = true

func _on_home_ui_inform_game_that_user_has_started_game():
	current_scene = next_scene(current_scene)
	reset_scene(current_scene)
	current_scene_background_music.play()
	home_ui.player_is_playing_a_level = true

func _on_home_ui_inform_game_that_settings_screen_are_displayed():
	home_ui.visible = false
	home_ui.is_menu_settings_being_displayed = true
	enter_settings_menu_sound.play()
	settings_menu.visible = true
	settings_menu.return_button.grab_focus()

func _on_settings_menu_inform_game_that_return_button_has_been_pressed(from_game_controller : bool):
	if current_scene == Scenes.HOME:
		if !from_game_controller:
			if settings_menu.visible:
				exit_settings_menu_sound.play()
			settings_menu.visible = false
			home_ui.visible = true
			home_ui.is_menu_settings_being_displayed = false
			home_ui.update_focus(home_ui.current_button_on_focus)
	else:
		player_node.is_menu_settings_being_displayed = !player_node.is_menu_settings_being_displayed
		robot_node.is_menu_settings_being_displayed = !robot_node.is_menu_settings_being_displayed
		settings_menu.visible = !settings_menu.visible
		if settings_menu.visible:
			enter_settings_menu_sound.play()
		else:
			exit_settings_menu_sound.play()
		settings_menu.return_button.grab_focus()

func draw_grid():
	var viewport_dimensions = get_viewport_rect().size
	print(viewport_dimensions)
	# NOTE : On Windows the fullscreen mode takes 1 pixel for each border (read Godot documentation)
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		viewport_dimensions += Vector2(2, 2)
	var pixel_grid_size = (viewport_dimensions / grid_size)
	var custom_gray = Color.GRAY
	custom_gray.a = 0.3
	for i in range(0, pixel_grid_size.x):
		for j in range(0, pixel_grid_size.y):
			var x = (i * grid_size)
			var y = (j * grid_size)
			self.draw_line(Vector2(x, y), Vector2(x + grid_size, y), custom_gray, grid_thickness)
			self.draw_line(Vector2(x, y), Vector2(x, y + grid_size), custom_gray, grid_thickness)
	# NOTE : This edge-case does not work for non-multiples of 2 ... bummer
	var last_row = pixel_grid_size.y * grid_size
	for i in range(0, pixel_grid_size.x):
		var x = (i * grid_size)
		self.draw_line(Vector2(x, last_row), Vector2(x + grid_size, last_row), custom_gray, grid_thickness)
	var last_col = pixel_grid_size.x * grid_size
	for j in range(0, pixel_grid_size.y):
		var y = (j * grid_size)
		self.draw_line(Vector2(last_col, y), Vector2(last_col, y + grid_size), custom_gray, grid_thickness)
	pass
