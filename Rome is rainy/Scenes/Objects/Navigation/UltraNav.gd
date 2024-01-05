extends NavigationAgent2D

var point_target

@onready var parent = get_parent()

func _ready():
	pass

func _physics_process(delta):
	parent.check_actions(delta)

func set_entity_target(target):
	await get_tree().physics_frame
	if target.is_visible_in_tree():
		target_position = target.position
	elif is_navigation_finished():
		pass

func get_target():
	if is_navigation_finished():
		return
	var next_path_position = get_next_path_position()
	point_target = next_path_position

