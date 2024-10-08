extends CharacterBody2D

class_name BeatTheRobotPlayer

enum MovementDirection { LEFT, RIGHT, UP, DOWN }
var current_movement_direction : MovementDirection

@onready var geometry_collision_shape_2d = $GeometryCollisionShape2D
@onready var graphics_sprite_2d = $GraphicsSprite2D
@onready var ray_cast_2d_down = $RayCast2DDown
@onready var ray_cast_2d_right = $RayCast2DRight
@onready var ray_cast_2d_left = $RayCast2DLeft
@onready var ray_cast_2d_up = $RayCast2DUp
@onready var ray_cast_2d_down_right = $RayCast2DDownRight
@onready var ray_cast_2d_down_left = $RayCast2DDownLeft
@onready var ray_cast_2d_up_right = $RayCast2DUpRight
@onready var ray_cast_2d_up_left = $RayCast2DUpLeft

enum BoundaryCondition { RIGID, LOOP }

@export_group("Movement Characteristics")
@export var ray_cast_size : float = 32
@export var MOVEMENT_IN_PIXELS = 32
@export var SPEED_DELAY_FACTOR = 5
@export var show_console_output : bool = false
@export_enum("_process", "_physics_process") var update_function : int = 1
@export var use_viewport_dimensions_for_world_size : bool = false
@export var boundary_condition : BoundaryCondition = BoundaryCondition.RIGID
@export_subgroup("Boundary Distance")
@export var boundary_distance : int = 32
const disable_usage_of_personalized_inputs : bool = true

var viewport_dimensions : Vector2 = Vector2.ZERO
var movement_delay = 0.0
var level_has_started : bool = false
var is_menu_settings_being_displayed : bool = false

func set_initial_position(position_to_set : Vector2):
	self.position = position_to_set
	geometry_collision_shape_2d.position = position_to_set

func move_left():
	current_movement_direction = MovementDirection.LEFT
	if !ray_cast_2d_left.is_colliding():
		self.position.x -= (MOVEMENT_IN_PIXELS)
		if boundary_condition == BoundaryCondition.RIGID:
			if self.position.x < boundary_distance:
				self.position.x = boundary_distance
		elif boundary_condition == BoundaryCondition.LOOP:
			if self.position.x < 0.0:
				self.position.x = viewport_dimensions.x

func move_right():
	current_movement_direction = MovementDirection.RIGHT
	if !ray_cast_2d_right.is_colliding():
		self.position.x += (MOVEMENT_IN_PIXELS)
		if boundary_condition == BoundaryCondition.RIGID:
			if self.position.x > viewport_dimensions.x - boundary_distance:
				self.position.x = viewport_dimensions.x - boundary_distance
		elif boundary_condition == BoundaryCondition.LOOP:
			if self.position.x > viewport_dimensions.x:
				self.position.x = 0.0

func move_up():
	current_movement_direction = MovementDirection.UP
	if !ray_cast_2d_up.is_colliding():
		self.position.y -= (MOVEMENT_IN_PIXELS)
		if boundary_condition == BoundaryCondition.RIGID:
			if self.position.y < boundary_distance:
				self.position.y = boundary_distance
		elif boundary_condition == BoundaryCondition.LOOP:
			if self.position.y < 0.0:
				self.position.y = viewport_dimensions.y

func move_down():
	current_movement_direction = MovementDirection.DOWN
	if !ray_cast_2d_down.is_colliding():
		self.position.y += (MOVEMENT_IN_PIXELS)
		if boundary_condition == BoundaryCondition.RIGID:
			if self.position.y > viewport_dimensions.y - boundary_distance:
				self.position.y = viewport_dimensions.y - boundary_distance
		elif boundary_condition == BoundaryCondition.LOOP:
			if self.position.y > viewport_dimensions.y:
				self.position.y = 0.0

func player_movement(delta:float):
	if !is_menu_settings_being_displayed:
		# NOTE : This part of the script handles the movement (with speed)
		# for the player, it does not use the _*_input(event) functions
		# since the movement is done to understand the _physics_process()/_process()
		# function and not relying on the self.move_and_slide() as well
		# to have same speed across input devices (keyboard, dpad, motion axis). 
		# It is also important the if-elseif structure to limit the player to one action
		# decision 
		movement_delay += delta
		if movement_delay >= (delta * SPEED_DELAY_FACTOR):
			if Input.is_action_pressed("player_move_left"):
				move_left()
			elif Input.is_action_pressed("player_move_right"):
				move_right()
			elif Input.is_action_pressed("player_move_up"):
				move_up()
			elif Input.is_action_pressed("player_move_down"):
				move_down()
			movement_delay = 0.0

func _ready():
	pass

func _process(delta):
	ray_cast_2d_down.target_position = Vector2(0, +ray_cast_size)
	ray_cast_2d_right.target_position = Vector2(+ray_cast_size, 0)
	ray_cast_2d_left.target_position = Vector2(-ray_cast_size, 0)
	ray_cast_2d_up.target_position = Vector2(0, -ray_cast_size)
	if use_viewport_dimensions_for_world_size:
		viewport_dimensions = get_viewport_rect().size
	else:
		viewport_dimensions = Vector2(1024, 1024)
	if level_has_started and update_function == 0:
		if show_console_output:
			print("_process called every ", delta, " seconds")
			print("position: ", self.position)
		player_movement(delta)
	pass

func _physics_process(delta):
	if level_has_started and update_function == 1:
		if show_console_output:
			print("_physics_process called every ", delta, " seconds")
			print("position: ", self.position)
		player_movement(delta)
	pass
	
func _unhandled_key_input(event):
	if !disable_usage_of_personalized_inputs:
		if level_has_started:
			if event is InputEventKey:
				if event.pressed:
					match event.keycode:
						Key.KEY_LEFT:
							move_left()
						Key.KEY_RIGHT:
							move_right()
						Key.KEY_UP:
							move_up()
						Key.KEY_DOWN:
							move_down()
						Key.KEY_T:
							print(ray_cast_2d_down.get_collision_point())
	pass
	
func _unhandled_input(event):
	if !disable_usage_of_personalized_inputs:
		if level_has_started:
			if event is InputEventJoypadButton:
				if event.pressed:
					match event.button_index:
						JoyButton.JOY_BUTTON_DPAD_LEFT:
							move_left()
						JoyButton.JOY_BUTTON_DPAD_RIGHT:
							move_right()
						JoyButton.JOY_BUTTON_DPAD_UP:
							move_up()
						JoyButton.JOY_BUTTON_DPAD_DOWN:
							move_down()
						_:
							pass
			if event is InputEventJoypadMotion:
				if abs(event.axis_value) > 0.1:
					pass
	pass
