class_name PlayerCharacter
extends RigidBody2D

@onready var ignite : CPUParticles2D = $igniteparticle

@onready var stats : Node2D = $Stats

var score : int = 0
var my_team : String = "Team-A"
# Ship properties
var thrust : float
var reverse_thrust : float
var brake_thrust : float
var rotation_speed : float



func _ready():
	add_to_group(my_team)
	set_ship_mass()
	
	

func _process(delta: float) -> void:
	# Handle user input
	handle_input(delta)

func set_speed():
	thrust = (stats.speed * mass) / 1.2
	reverse_thrust = (stats.speed * mass) / 1.4
	brake_thrust = ((stats.speed * mass) / 1.4) * 2
	rotation_speed = ((stats.speed * mass) / 1.4)

func set_ship_mass():
	if stats.health/10 >= 1:
		set_mass(stats.health/10)
	else:
		set_mass(1)
	set_speed()

func handle_input(delta: float) -> void:
	# Thrust
	var thrust_force : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("up"):
		thrust_force = Vector2.UP.rotated(rotation) * thrust
		ignite.emitting = true
	elif Input.is_action_pressed("down"):
		thrust_force = -Vector2.UP.rotated(rotation) * reverse_thrust
		ignite.emitting = false
	else:
		ignite.emitting = false
	# Brake
	var brake_force : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("brake"):
		brake_force = -linear_velocity.normalized() * brake_thrust

	# Rotation
	var rotation_direction : int = 0
	if Input.is_action_pressed("left"):
		rotation_direction = -1
	elif Input.is_action_pressed("right"):
		rotation_direction = 1

	# Apply forces
	apply_thrust(thrust_force, delta)
	apply_thrust(brake_force, delta)
	apply_rotation(rotation_direction, delta)

func apply_thrust(force: Vector2, _delta: float) -> void:
	# Apply thrust force
	var acceleration : Vector2 = force / mass
	apply_central_impulse(acceleration)

func apply_rotation(direction: int, delta: float) -> void:
	# Apply rotation
	var rotation_amount : float = rotation_speed * direction
	angular_velocity = rotation_amount * delta / mass





