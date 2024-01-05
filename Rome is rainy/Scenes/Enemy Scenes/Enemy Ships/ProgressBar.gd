extends ProgressBar

@onready var parent = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = parent.max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	value = parent.health
