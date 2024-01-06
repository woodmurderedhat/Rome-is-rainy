extends Node2D

# Shooting properties
var bullet_scene : PackedScene = preload("res://Scenes/Objects/Bulleets/bulletalpha.tscn")  # Replace with the path to your bullet scene
var shoot_speed : float = 1500.0
var can_shoot : bool = true
var shoot_cooldown : float = 0.1  # Adjust as needed
var shoot_radius : float = 128.0
var bullet_lifetime : float = 10

@onready var parent = get_parent()
@onready var shoot_timer : Timer = $ShootTimer
@onready var particle : CPUParticles2D = $CPUParticles2D
# Called when the node enters the scene tree for the first time.
func _ready():
	particle.emitting = false
	particle.one_shot = true
	shoot_timer.wait_time = shoot_cooldown


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func shoot() -> void:
	await get_tree().physics_frame
	_shoot()
	pass
# Function to handle shooting
func _shoot() -> void:
	# Instantiate a bullet scene
	var bullet_instance : Node2D = bullet_scene.instantiate()

	# Set the bullet's position and rotation
	bullet_instance.global_position = $Marker2D.global_position
	bullet_instance.rotation = parent.rotation
	bullet_instance.lifetime = bullet_lifetime

	# Add the bullet to the scene
	get_parent().get_parent().add_child(bullet_instance)

	# Apply force to the bullet in the forward direction
	var bullet_force : Vector2 = Vector2(0, -1).rotated(parent.rotation) * shoot_speed
	bullet_instance.apply_central_impulse(bullet_force)
	particle.emitting = true



func _on_shoot_timer_timeout():
	call_deferred("shoot")
	shoot_timer.stop()


func _on_area_2d_body_entered(body):
	if body != self and body.is_in_group("Ship"):
		if body.my_team != parent.my_team:
			if shoot_timer.is_stopped():
				shoot_timer.start()
			else:
				pass
		else:
			pass
	else:
		pass
func _on_area_2d_body_exited(body):
	if body.is_in_group("Ship"):
		if not shoot_timer.is_stopped():
			shoot_timer.stop()
	else:
		pass
