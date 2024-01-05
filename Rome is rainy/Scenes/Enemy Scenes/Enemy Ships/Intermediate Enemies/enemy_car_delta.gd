extends RigidBody2D

var move_target : Vector2

var score : int = 0
var max_life = 100
var life = 100

var thrust : float = randf_range(45.0,100.0)
var rotation_speed : float = randf_range(45.0,100.0)
var reverse_thrust : float = randf_range(45.0,100.0)
var brake_thrust : float = randf_range(450.0,1500.0)

# Shooting properties
var bullet_scene : PackedScene = preload("res://Scenes/Objects/Bulleets/bulletalpha.tscn")  # Replace with the path to your bullet scene
var shoot_speed : float = 1500.0
var can_shoot : bool = true
var shoot_cooldown : float = 0.5  # Adjust as needed

var destination : Vector2
var has_target = false
var current_target : RigidBody2D = null

enum STATES{Racing, Attacking}
var state = STATES.Racing

@onready var nav : NavigationAgent2D = $UltraNav
@onready var fronteye : RayCast2D = $FrontRayCast2D
@onready var lefteye : RayCast2D = $LeftRayCast2D
@onready var righteye : RayCast2D = $RightRayCast2D
@onready var backeye : RayCast2D = $BackRayCast2D
@onready var ignite : CPUParticles2D = $igniteparticle

func _ready():
	pass

func _process(delta):
	check_actions(delta)
		
		# Handle shooting cooldown
	if !can_shoot:
		shoot_cooldown -= delta
		if shoot_cooldown <= 0.0:
			can_shoot = true
			shoot_cooldown = 0.5  # Reset the cooldown
func _physics_process(_delta):
	pass

		# Handle shooting cooldown

func shoot() -> void:
	call_deferred("_shoot")

func _shoot() -> void:
	# Instantiate a bullet scene
	var bullet_instance : RigidBody2D = bullet_scene.instantiate()

	# Set the bullet's position and rotation
	bullet_instance.global_position = $Marker2D.global_position
	bullet_instance.rotation = rotation

	# Add the bullet to the scene
	get_parent().add_child(bullet_instance)

	# Apply force to the bullet in the forward direction
	var bullet_force : Vector2 = Vector2(0, -1).rotated(rotation) * shoot_speed
	bullet_instance.apply_central_impulse(bullet_force)

func check_actions(delta: float):
	use_eyes(delta)
	if state == STATES.Attacking:
		get_target(delta)
		apply_forces(delta)
	elif state == STATES.Racing:
		locate_nearest_checkpoint(delta)
	

func get_target(delta: float) -> void:
	nav.get_target()
	var rotation_direction : int = 0
	var direction = Vector2.UP.rotated(rotation)
	if has_target:
		direction = (nav.point_target - global_position).normalized()
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
	var checkpoints = get_tree().get_nodes_in_group("checkpoint")
	var nearest_checkpoint = null
	var INFINITY = 1e18
	var nearest_distance_squared = INFINITY
	if checkpoints:
		for checkpoint in checkpoints:
			
			if checkpoint.is_visible_in_tree():  # Ignore the current enemy itself
				var distance_squared = position.distance_squared_to(checkpoint.global_position)
				if distance_squared < nearest_distance_squared:
					nearest_checkpoint = checkpoint
					nearest_distance_squared = distance_squared
						
		if nearest_checkpoint != null:
			nav.set_entity_target(nearest_checkpoint)
			get_target(delta)
		else:
			use_eyes(delta)

func locate_nearest_enemy(delta: float):
	var enemies = get_tree().get_nodes_in_group("scorable")
	var nearest_enemy = null
	var INFINITY = 1e18
	var nearest_distance_squared = INFINITY
	for enemy in enemies:
		if not current_target:  # Ignore the current enemy itself
			var distance_squared = position.distance_squared_to(enemy.global_position)
			if distance_squared < nearest_distance_squared:
				nearest_enemy = enemy
				nearest_distance_squared = distance_squared
						
		if nearest_enemy is RigidBody2D:
			has_target = true
			current_target = nearest_enemy
			nav.set_entity_target(nearest_enemy)
			get_target(delta)

func apply_rotation(direction: int, delta: float) -> void:
	# Apply rotation
	var rotation_amount : float = rotation_speed * direction
	angular_velocity = rotation_amount * delta / mass



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
	elif not fronteye.is_colliding() and not lefteye.is_colliding() and righteye.is_colliding():
		rotation_direction = -1
	#	apply_rotation(rotation_direction, delta)
	elif not fronteye.is_colliding() and lefteye.is_colliding() and not righteye.is_colliding():
		rotation_direction = 1
	elif not fronteye.is_colliding():
		thrust_force = Vector2.UP.rotated(rotation) * thrust
		ignite.emitting = true
	#	apply_thrust(thrust_force, delta)
	elif fronteye.is_colliding() and not lefteye.is_colliding() and not righteye.is_colliding():
		thrust_force = -Vector2.UP.rotated(rotation) * reverse_thrust
	#	apply_thrust(brake_force, delta)

	else:
		brake_force = -linear_velocity.normalized() * brake_thrust
		ignite.emitting = false



	# Shooting


	# Apply forces
	apply_thrust(brake_force, delta)
	apply_thrust(thrust_force, delta)
	apply_rotation(rotation_direction, delta)

func apply_forces(delta: float) -> void:
	if has_target and current_target.is_visible_in_tree():
		# Calculate the direction to the player
		var to_player : Vector2 = (current_target.global_position - global_position).normalized()

		# Rotation
		var angle_to_player : float = to_player.angle_to(Vector2.UP.rotated(rotation))

		var rotation_direction : int = 0
		if angle_to_player > 0.5:
		# Rotate clockwise
			rotation_direction = -1

		elif angle_to_player < -0.5:
		# Rotate counterclockwise
			rotation_direction = 1
	
		else:
			# Stop rotating
			shoot()
			can_shoot = false  # Set the cooldown
			rotation_direction = 0
		apply_rotation(rotation_direction, delta)

func _on_area_2d_body_entered(body):
	if body is RigidBody2D:
		state = STATES.Attacking
		nav.set_entity_target(body)
		current_target = body
	else:
		pass


func _on_area_2d_body_exited(body):
	if body == current_target:
		state = STATES.Racing
		current_target = null
	else:
		pass


func _on_shoot_area_body_entered(body):
	if body == current_target:
		shoot()
