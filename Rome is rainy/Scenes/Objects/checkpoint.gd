class_name RaceCheckpoint
extends RigidBody2D
@onready var timer : Timer = $Timer
@onready var deathtimer : Timer = $DeathTimer

var lifetime : float = 30.0
# Called when the node enters the scene tree for the first time.
func _ready():
	deathtimer.wait_time = lifetime
	deathtimer.one_shot = true
	deathtimer.start()
	
	$Area2D.set_deferred("monitoring", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_timer_timeout():
	timer.stop()
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Ship"):
		if body.stats.baggage < body.stats.max_baggage:
			body.stats.baggage += 1
			die()
		else:
			pass
	else:
		pass


func die():
	timer.wait_time = 5
	timer.start()
	visible = false
	$Area2D.set_deferred("monitoring", false)
func _on_death_timer_timeout():
	die()
