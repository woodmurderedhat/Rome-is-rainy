extends Node2D

@onready var parent = get_parent()
#level
var max_level : int = 100
@export var level : int = 1
var max_level_exp : int = 1000
var level_exp : int = 0
#speed
var max_speed : float = 100.0
@export var speed : float = 100.0
var max_speed_exp : int = 1000
var speed_exp : int = 0
#health
var max_health : float = 1000.0
@export var health : float = 1000.0
var max_health_exp : int = 1000
var health_exp : int = 0

#inventory
var max_baggage : int = 100
var baggage : int = 0

#some fuckery
var xelta : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if baggage >= max_baggage:
		if parent is Epsilon:
			parent.brain.state = parent.brain.STATES.RETURNING
		else:
			return
	else:
		return
	xelta = delta

func level_up():
	if level < max_level:
		level += 1
func add_level_exp(amount : int):
	if level_exp < max_level_exp:
		if (level_exp + amount) < max_level_exp:
			level_exp += amount
		elif (level_exp + amount) > max_level_exp:
			level_exp = level_exp + amount - max_level_exp
			level_up()
	elif level_exp >= max_level_exp:
		level_up()

func speed_up():
	if speed < max_speed:
		speed += 1
		parent.set_speed()
func add_speed_exp(amount : int):
	if speed_exp < max_speed_exp:
		if (speed_exp + amount) < max_speed_exp:
			speed_exp += amount
		elif (speed_exp + amount) > max_speed_exp:
			speed_exp = speed_exp + amount - max_speed_exp
			speed_up()
	elif speed_exp >= max_speed_exp:
		speed_up()

func health_up():
	if health < max_health:
		health += 1
		parent.set_ship_mass()
func add_health_exp(amount : int):
	if health_exp < max_health_exp:
		if (health_exp + amount) < max_health_exp:
			health_exp += amount
		elif (health_exp + amount) > max_health_exp:
			health_exp = health_exp + amount - max_health_exp
			health_up()
	elif health_exp >= max_health_exp:
		health_up()

func apply_hit_forces(thrust : Vector2, delta : float):
	parent.apply_thrust(thrust, delta)
 
func apply_damage(damage: float):
	if health > 0:
		health -= damage
func _on_hitbox_body_entered(body):
	if body is RigidBody2D:
		var hit_force = ((-body.linear_velocity * body.mass) - parent.linear_velocity).normalized()
		apply_hit_forces(hit_force, xelta)
		if body.has_method("damage"):
			apply_damage(body.damage)
