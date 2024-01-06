class_name Epsilon
extends RigidBody2D

var stats_scene : PackedScene = load("res://Scenes/Objects/Stats/stats.tscn")
var particles_scene : PackedScene = load("res://Scenes/Objects/ParticleEffects/basic_ship_particle_effects.tscn")
var brain_scene : PackedScene = load("res://Scenes/Objects/ArtificialIntellects/epsilon_brain.tscn")

var my_dock : RigidBody2D
var my_team : String
var enemy_team_alpha : String = "Team-B"
var enemy_team_beta : String = "Team-C"
@onready var ignition : Node2D
@onready var brain : Node2D
@onready var stats : Node2D

# Ship properties
var thrust : float
var reverse_thrust : float
var brake_thrust : float
var rotation_speed : float

func _ready():
	
	make_scene()

func _process(_delta: float) -> void:
	pass

func make_scene():
	await get_tree().physics_frame
	_make_scene()

func _make_scene() -> void:
	var stats_instance : Node2D = stats_scene.instantiate()
	var particles_instance : Node2D = particles_scene.instantiate()
	var brain_instance : Node2D = brain_scene.instantiate()

		# Add the stats to the scene
	add_child(stats_instance)
	add_child(particles_instance)

	add_child(brain_instance)
	
	stats = stats_instance
	brain = brain_instance
	ignition = particles_instance

	set_ship_mass()

func set_speed():
	thrust = (stats.speed * mass) / 1.4
	reverse_thrust = (stats.speed * mass) / 1.4
	brake_thrust = ((stats.speed * mass) / 1.4) * 4
	rotation_speed = ((stats.speed * mass) / 1.4)

func set_ship_mass():
	if stats.health/10 >= 1:
		set_mass(stats.health/10)
	else:
		set_mass(1)
	set_speed()

func apply_thrust(force: Vector2, _delta: float) -> void:
	# Apply thrust force
	var acceleration : Vector2 = force / mass
	apply_central_impulse(acceleration)
	ignition.ignite()

func apply_rotation(direction: int, delta: float) -> void:
	# Apply rotation
	var rotation_amount : float = rotation_speed * direction
	angular_velocity = rotation_amount * delta / mass


