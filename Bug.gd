extends Node2D

const MAX_DISTANCE = 100
const MAX_VELOCITY = 10

var origin
var velocity = Vector2.ZERO

func _ready():
	add_to_group("Food")
	origin = position

func _physics_process(delta):
	# move like a bug
	var jitter = Vector2(rand_range(-1, 1), rand_range(-1, 1))
	# bias movement towards the origin
	var bias = (origin - position) / MAX_DISTANCE
	var acceleration = bias + jitter
	velocity += acceleration
	# cap velocity
	if velocity.x > MAX_VELOCITY or velocity.y > MAX_VELOCITY:
		velocity = velocity.normalized() * MAX_VELOCITY
	position += velocity * delta
