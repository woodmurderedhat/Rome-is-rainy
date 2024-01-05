extends RigidBody2D

var score : int = 0
var max_life = 100
var life = 100
# Ship properties
var ship_mass : float = 1.0
var thrust : float = 2000000.0
var reverse_thrust : float = 1000000.0
var brake_thrust : float = 5000000.0  # Adjust as needed
var friction_coefficient : float = 0.0  # Adjust as needed
var rotation_speed : float = 100000.0

# Shooting properties
var bullet_scene : PackedScene = preload("res://Scenes/Objects/Bulleets/bulletalpha.tscn")  # Replace with the path to your bullet scene
var shoot_speed : float = 1500.0
var can_shoot : bool = true
var shoot_cooldown : float = 0.5  # Adjust as needed

@onready var hitbox : Area2D = $Hitbox
@onready var ignite : CPUParticles2D = $igniteparticle

@onready var fronteye : RayCast2D = $FrontRayCast2D
@onready var lefteye : RayCast2D = $LeftRayCast2D
@onready var righteye : RayCast2D = $RightRayCast2D
@onready var backeye : RayCast2D = $BackRayCast2D

enum States {ATTACKPLAYER, NORMALMODE}
var state = States.NORMALMODE

var player : RigidBody2D = null
var ai_brake_distance : float = 50.0 
var has_target = false
var target : Vector2

func _process(delta: float) -> void:
	# Handle user input
	if state == States.NORMALMODE:
		use_eyes(delta)
	elif state == States.ATTACKPLAYER:
		apply_forces(delta)

	# Handle shooting cooldown
	if !can_shoot:
		shoot_cooldown -= delta
		if shoot_cooldown <= 0.0:
			can_shoot = true
			shoot_cooldown = 0.5  # Reset the cooldown

func use_eyes(delta: float) -> void:
	# Thrust
	var thrust_force : Vector2 = Vector2.ZERO
	var brake_force : Vector2 = Vector2.ZERO
	var rotation_direction : int = 0
	if fronteye.is_colliding() and lefteye.is_colliding() and righteye.is_colliding():
		thrust_force = -Vector2.UP.rotated(rotation) * reverse_thrust
	#	apply_thrust(brake_force, delta)
	elif fronteye.is_colliding() and not lefteye.is_colliding() and righteye.is_colliding():
		rotation_direction = -1
	#	apply_rotation(rotation_direction, delta)
	elif fronteye.is_colliding() and lefteye.is_colliding() and not righteye.is_colliding():
		rotation_direction = 1
	#	apply_rotation(rotation_direction, delta)
	elif not fronteye.is_colliding() and lefteye.is_colliding() and righteye.is_colliding():
		thrust_force = -Vector2.UP.rotated(rotation) * reverse_thrust
	#	apply_thrust(brake_force, delta)
	elif not fronteye.is_colliding() and not lefteye.is_colliding() and righteye.is_colliding():
		rotation_direction = -1
	#	apply_rotation(rotation_direction, delta)
	elif not fronteye.is_colliding() and lefteye.is_colliding() and not righteye.is_colliding():
		rotation_direction = 1
	elif not fronteye.is_colliding():
		thrust_force = Vector2.UP.rotated(rotation) * thrust
		ignite.emitting = true
	#	apply_thrust(thrust_force, delta)
	elif Input.is_action_pressed("down"):
		thrust_force = -Vector2.UP.rotated(rotation) * reverse_thrust
		ignite.emitting = false
	else:
		brake_force = -linear_velocity.normalized() * brake_thrust
		ignite.emitting = false



	# Shooting


	# Apply forces
	apply_thrust(brake_force, delta)
	apply_thrust(thrust_force, delta)
	apply_rotation(rotation_direction, delta)

func apply_thrust(force: Vector2, _delta: float) -> void:
	# Apply thrust force
	var acceleration : Vector2 = force / mass
	apply_central_impulse(acceleration)

func apply_rotation(direction: int, delta: float) -> void:
	# Apply rotation
	var rotation_amount : float = rotation_speed * direction
	angular_velocity = rotation_amount * delta / mass

# Function to handle shooting
func shoot() -> void:
	# Instantiate a bullet scene
	var bullet_instance : Node2D = bullet_scene.instantiate()

	# Set the bullet's position and rotation
	bullet_instance.global_position = $Marker2D.global_position
	bullet_instance.rotation = rotation

	# Add the bullet to the scene
	get_parent().add_child(bullet_instance)

	# Apply force to the bullet in the forward direction
	var bullet_force : Vector2 = Vector2(0, -1).rotated(rotation) * shoot_speed
	bullet_instance.apply_central_impulse(bullet_force)


func _on_hitbox_body_entered(body):
	if body != self:
		if life > 0:
			life -= 1
		elif life <= 0:
			queue_free()

func apply_forces(delta: float) -> void:
	if has_target:
		# Calculate the direction to the player
		var to_player : Vector2 = (player.global_position - global_position).normalized()

		# Rotation
		var angle_to_player : float = to_player.angle_to(Vector2.UP.rotated(rotation))

		var rotation_direction : int = 0
		if angle_to_player > 0.1:
		# Rotate clockwise
			rotation_direction = -1

		elif angle_to_player < -0.1:
		# Rotate counterclockwise
			rotation_direction = 1
	
		else:
			# Stop rotating
			shoot()
			can_shoot = false  # Set the cooldown
			rotation_direction = 0
		apply_rotation(rotation_direction, delta)

func _on_sense_perception_body_entered(body):
	if body is PlayerCharacter:
		state = States.ATTACKPLAYER
		player = body
		target = player.global_position
		has_target = true
	elif body != PlayerCharacter:
		state = States.NORMALMODE
		has_target = false


func _on_sense_perception_body_exited(body):
	if body is PlayerCharacter:
		state = States.NORMALMODE
		player = null
		target = self.position
		has_target = false
	else:
		pass
