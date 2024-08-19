extends CharacterBody2D

class_name BeatTheRobotRobot

@onready var geometry_collision_shape_2d = $GeometryCollisionShape2D

func _ready():
	var ray_cast_left = RayCast2D.new()
	var ray_cast_right = RayCast2D.new()
	var ray_cast_up = RayCast2D.new()
	var ray_cast_down = RayCast2D.new()
	ray_cast_left.target_position = Vector2(-30, 0)
	ray_cast_right.target_position = Vector2(30, 0)
	ray_cast_down.target_position = Vector2(0, 30)
	ray_cast_up.target_position = Vector2(0, -30)
	self.add_child(ray_cast_left)
	self.add_child(ray_cast_right)
	self.add_child(ray_cast_down)
	self.add_child(ray_cast_up)
	pass

func is_ray_cast_colliding():
	# NOTE : This is one way of fetching the values from the editor
	# but those are persistent so might not be so good hardcoding this
	# value if something else changes for such scene ...
	return \
	self.get_node("@RayCast2D@2").is_colliding() or \
	self.get_node("@RayCast2D@3").is_colliding() or \
	self.get_node("@RayCast2D@4").is_colliding() or \
	self.get_node("@RayCast2D@5").is_colliding()

func set_initial_position(_position_to_set : Vector2):
	pass

func _physics_process(_delta):
	pass
