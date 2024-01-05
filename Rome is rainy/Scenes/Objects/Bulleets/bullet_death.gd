extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = lifetime
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	queue_free()
