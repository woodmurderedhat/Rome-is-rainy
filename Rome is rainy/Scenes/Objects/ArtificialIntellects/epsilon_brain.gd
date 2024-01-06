extends Node2D
@onready var eyes = $Eyes
@onready var parent = get_parent()
#eyes state
enum SEEING{INFRONT,LEFT,RIGHT,BEHIND,LEFTSIDEWAYS,RIGHTSIDEWAYS,FRONTSIDEWAYS,ALLCLEAR}
enum STATES{WANDERING,FARMING,RETURNING,ATTACKING,DEFENDING}
var state = STATES.WANDERING
@onready var nav = $UltraNav

var has_target = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	choose_actions(delta)

func choose_actions(delta: float):
	if state == STATES.WANDERING:
		eyeing(delta)
		locate_nearest_checkpoint(delta)
	if state == STATES.FARMING:
		locate_nearest_checkpoint(delta)
	if state == STATES.RETURNING:
		nav.set_entity_target(parent.my_dock)
		get_target(delta)

func locate_nearest_checkpoint(delta: float):
	var checkpoints = get_tree().get_nodes_in_group("checkpoint")
	var nearest_checkpoint = null
	var INFINITY = 1e18
	var nearest_distance_squared = INFINITY
	if checkpoints != null:
		for checkpoint in checkpoints:
			if checkpoint.is_visible_in_tree():  # Ignore the current enemy itself
				var distance_squared = parent.position.distance_squared_to(checkpoint.global_position)
				if distance_squared < nearest_distance_squared:
					nearest_checkpoint = checkpoint
					nearest_distance_squared = distance_squared
						
		if nearest_checkpoint != null:
			state = STATES.FARMING
			nav.set_entity_target(nearest_checkpoint)
			get_target(delta)
		else:
			state = STATES.WANDERING
	else:
		state = STATES.WANDERING

func get_target(delta: float) -> void:
	nav.get_target()
	var rotation_direction : int = 0
	var direction : Vector2
	var thrust_force : Vector2 = Vector2.UP.rotated(parent.rotation) * parent.thrust
	if has_target:
		direction = (nav.point_target - parent.global_position).normalized()
		var angle_to_direction : float = direction.angle_to(Vector2.UP.rotated(parent.rotation))
		if angle_to_direction > 0.2:
		# Rotate clockwise
			rotation_direction = -1
			
		elif angle_to_direction < -0.2:
		# Rotate counterclockwise
			rotation_direction = 1
			
		if angle_to_direction == 0:
			rotation_direction = 0
			
	parent.apply_thrust(thrust_force, delta)
	parent.apply_rotation(rotation_direction, delta)
	

func eyeing(delta: float):
	var thrust_force
	var rotation_direction = 0
	eyes.use_eyes()
	if eyes.state == SEEING.ALLCLEAR:
		thrust_force = Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = 0
	if eyes.state == SEEING.FRONTSIDEWAYS:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.reverse_thrust
		rotation_direction = 0
	if eyes.state == SEEING.RIGHTSIDEWAYS:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = -1
	if eyes.state == SEEING.LEFTSIDEWAYS:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = 1
	if eyes.state == SEEING.RIGHT:
		thrust_force = Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = -1
	if eyes.state == SEEING.LEFT:
		thrust_force = Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = 1
	if eyes.state == SEEING.INFRONT:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = 1
	if eyes.state == SEEING.BEHIND:
		thrust_force = Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = 0
	parent.apply_rotation(rotation_direction,delta)
	parent.apply_thrust(thrust_force,delta)
