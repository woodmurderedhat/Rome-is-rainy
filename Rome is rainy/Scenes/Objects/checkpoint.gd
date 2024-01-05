class_name RaceCheckpoint
extends RigidBody2D
@onready var timer : Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.set_deferred("monitoring", true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_timer_timeout():
	timer.stop()
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("scorable") or body is PlayerCharacter:
		body.score += 1
		timer.wait_time = 60
		timer.start()
		visible = false
		$Area2D.set_deferred("monitoring", false)

	else:
		pass

