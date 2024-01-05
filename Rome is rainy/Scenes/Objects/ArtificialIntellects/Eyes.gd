extends Node2D

enum SEEING{INFRONT,LEFT,RIGHT,BEHIND,LEFTSIDEWAYS,RIGHTSIDEWAYS,FRONTSIDEWAYS,ALLCLEAR}
var state = SEEING.ALLCLEAR
@onready var fronteye : RayCast2D = $FrontRayCast2D
@onready var lefteye : RayCast2D = $LeftRayCast2D
@onready var righteye : RayCast2D = $RightRayCast2D
@onready var backeye : RayCast2D = $BackRayCast2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func use_eyes():
	if not fronteye.is_colliding() and not lefteye.is_colliding() and not righteye.is_colliding() and not backeye.is_colliding():
		state = SEEING.ALLCLEAR
	elif fronteye.is_colliding() and lefteye.is_colliding() and righteye.is_colliding():
		state = SEEING.FRONTSIDEWAYS
	elif fronteye.is_colliding() and not lefteye.is_colliding() and righteye.is_colliding():
		state = SEEING.RIGHTSIDEWAYS
	elif fronteye.is_colliding() and lefteye.is_colliding() and not righteye.is_colliding():
		state = SEEING.LEFTSIDEWAYS
	elif not fronteye.is_colliding() and not lefteye.is_colliding() and righteye.is_colliding():
		state = SEEING.RIGHT
	elif not fronteye.is_colliding() and lefteye.is_colliding() and not righteye.is_colliding():
		state = SEEING.LEFT
	elif fronteye.is_colliding() and not lefteye.is_colliding() and not righteye.is_colliding():
		state = SEEING.INFRONT
	elif backeye.is_colliding():
		state = SEEING.BEHIND
	else:
		state = SEEING.ALLCLEAR
