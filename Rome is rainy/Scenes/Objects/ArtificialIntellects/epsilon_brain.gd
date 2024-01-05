extends Node2D
@onready var eyes = $Eyes
@onready var parent = get_parent()
#eyes state
enum SEEING{INFRONT,LEFT,RIGHT,BEHIND,LEFTSIDEWAYS,RIGHTSIDEWAYS,FRONTSIDEWAYS,ALLCLEAR}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.brake_thrust
		rotation_direction = -1
	if eyes.state == SEEING.LEFTSIDEWAYS:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.brake_thrust
		rotation_direction = 1
	if eyes.state == SEEING.RIGHT:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = -1
	if eyes.state == SEEING.LEFT:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.thrust
		rotation_direction = 1
	if eyes.state == SEEING.INFRONT:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.brake_thrust
		rotation_direction = 1
	if eyes.state == SEEING.BEHIND:
		thrust_force = -Vector2.UP.rotated(parent.rotation) * parent.brake_thrust
		rotation_direction = 0
	parent.apply_rotation(rotation_direction,delta)
	parent.apply_thrust(thrust_force,delta)
