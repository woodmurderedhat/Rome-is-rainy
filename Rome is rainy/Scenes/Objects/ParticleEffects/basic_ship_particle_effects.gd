extends Node2D

@onready var ignition : CPUParticles2D = $igniteparticle

# Called when the node enters the scene tree for the first time.
func _ready():
	ignition.one_shot = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func ignite():
	if not ignition.emitting:
		ignition.emitting = true
