extends RigidBody2D

var level : int = 1

var coins : int = 101
@export var spawn_scene : PackedScene 
var spawn_price : int = 100
@export var my_team : String

var max_spawn_amount : int = 101
var spawn_amount : int = 0

var max_spawn_time : float = 1.0
var spawn_time : float = 1.0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if spawn_amount < max_spawn_amount:
		if coins >= spawn_price:
			spawn_time -= delta
			if spawn_time <= 0.0:
				spawn()
				spawn_time = max_spawn_time
		else:
			pass
	else: 
		pass


func spawn():
	spawn_amount += 1
	coins -= spawn_price
	var spawn_instance = spawn_scene.instantiate()

	# Set the spawn's position and rotation
	spawn_instance.global_position = $Marker2D.global_position
	spawn_instance.rotation = rotation
	spawn_instance.my_dock = self
	spawn_instance.my_team = my_team
	spawn_instance.add_to_group(my_team)
	# Add the spawn to the scene
	get_parent().add_child(spawn_instance)






func _on_area_2d_body_entered(body):
	if body.is_in_group("Ship"):
		await get_tree().physics_frame
		if body.stats.baggage > 0:
			coins += body.stats.baggage
			body.stats.baggage = 0
			if body is Epsilon:
				if body.brain.state == body.brain.STATES.RETURNING:
					body.brain.state = body.brain.STATES.WANDERING
		else:
			return
	else:
		return
	pass
