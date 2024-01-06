extends RigidBody2D
var lifetime = 5.0
var death_scene : PackedScene = preload("res://Scenes/Objects/Bulleets/bulletdeath.tscn")
@onready var deathtimer : Timer = $DeathTimer
var damage : float = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	deathtimer.wait_time = lifetime
	deathtimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func die():
	var death_instance : Node2D = death_scene.instantiate()

	# Set the bullet's position and rotation
	death_instance.global_position = global_position
	death_instance.rotation = rotation

	# Add the bullet to the scene
	get_parent().add_child.call_deferred(death_instance)
	queue_free()
func _on_death_timer_timeout():
	
	die()
	deathtimer.stop()


func _on_area_2d_body_entered(body):
	if body != self:
		if body is Epsilon or body is PlayerCharacter:
			if body.stats.health > 0:
				body.stats.health -= 1
				return
			return
		die()


func _on_area_2d_body_exited(body):
	if body is Epsilon or body is PlayerCharacter:
		if body.stats.health > 0:
			body.stats.health -= 1
		die()
	pass
