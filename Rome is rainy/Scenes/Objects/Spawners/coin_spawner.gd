extends Node2D

# Token to be spawned
@export var token_scene : PackedScene

# Spawning properties
var spawn_interval_min : float = 1.0
var spawn_interval_max : float = 2.0
var max_tokens_per_spawn : int = 5
var spawn_radius : float = 5.0

# Token force properties
var min_force : float = 50.0
var max_force : float = 100.0

# Timer for spawning
@onready var spawn_timer : Timer = $Timer

# Physics Body stat handles position of spawner
@onready var tespawner : RigidBody2D = $TeSpawner

func _ready():
	start_timer(randf_range(spawn_interval_min, spawn_interval_max))

func start_timer(time: float):
	# Create and connect the timer
	spawn_timer.wait_time = time
	spawn_timer.one_shot = true

	# Start the timer
	spawn_timer.start()

func spawn_token():
	# Instantiate a new token
	var token_instance = token_scene.instantiate()
	
	# Set the position of the token within the spawn radius
	var angle = deg_to_rad(randf_range(0, 360))
	var spawn_position = Vector2(cos(angle), sin(angle)) * randf_range(0, spawn_radius)
	token_instance.position = tespawner.global_position + spawn_position
	
	# Add the token to the scene
	get_parent().add_child(token_instance)
	
	# Apply a random force to the token
	var force = Vector2(randf_range(min_force, max_force), randf_range(min_force, max_force))
	token_instance.apply_central_impulse(force)


func _on_timer_timeout():
	# Spawn random number of tokens
	var num_tokens = randi() % (max_tokens_per_spawn + 1)
	
	for i in range(num_tokens):
		spawn_token()

	# Restart the timer
	start_timer(randf_range(spawn_interval_min, spawn_interval_max))
