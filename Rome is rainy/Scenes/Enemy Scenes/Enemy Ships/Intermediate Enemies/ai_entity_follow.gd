extends RigidBody2D

var move_target : Vector2
@onready var nav : NavigationAgent2D = $UltraNav

var score : int = 0
var max_life = 100
var life = 100

const speed = 100
var thrust : float = 2000.0
var rotation_speed : float = 1000.0
var destination : Vector2
var has_target = false

func _ready():
	pass

func _physics_process(delta: float):
	locate_nearest_checkpoint(delta)


func get_target(delta: float) -> void:
	nav.get_target()
	var rotation_direction : int = 0
	var direction = (nav.point_target - global_position).normalized()
	var angle_to_direction : float = direction.angle_to(Vector2.UP.rotated(rotation))
	if angle_to_direction > 0.1:
		# Rotate clockwise
		rotation_direction = -1
		apply_rotation(rotation_direction, delta)

	elif angle_to_direction < -0.1:
		# Rotate counterclockwise
		rotation_direction = 1
		apply_rotation(rotation_direction, delta)
	elif angle_to_direction == 0:
		rotation_direction = 0
		
		
		
	var thrust_force = Vector2.UP.rotated(rotation) * thrust
	apply_thrust(thrust_force, delta)
	
	
func apply_thrust(force: Vector2, delta: float) -> void:
	# Apply thrust force
	var acceleration : Vector2 = force / mass * delta
	apply_central_impulse(acceleration)

func locate_nearest_checkpoint(delta: float):
	if not has_target:
		var checkpoints = get_tree().get_nodes_in_group("checkpoint")
		var nearest_checkpoint = null
		var INFINITY = 1e18
		var nearest_distance_squared = INFINITY
		
		for checkpoint in checkpoints:
			if checkpoint:  # Ignore the current enemy itself
				var distance_squared = position.distance_squared_to(checkpoint.global_position)
				if distance_squared < nearest_distance_squared:
					nearest_checkpoint = checkpoint
					nearest_distance_squared = distance_squared
					
		if nearest_checkpoint:
			nav.set_entity_target(nearest_checkpoint)
			get_target(delta)


func apply_rotation(direction: int, delta: float) -> void:
	# Apply rotation
	var rotation_amount : float = rotation_speed * direction
	angular_velocity = rotation_amount * delta / mass

func create_path(target: Vector2):
	destination = target
	nav.target_position = destination
	has_target = true
