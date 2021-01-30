extends KinematicBody2D

enum {
	WAIT
	ATTACK
	PATROL	
}

const MAX_SPEED = 100
const RANGE = 200

var state = WAIT

var sightAngle = 0

func _ready():
	var ray = get_node("RayCast2D").cast_to.angle()
	var beam = get_node("Line2D").points
	
func _process(delta):
	match state:
		WAIT:
			pass
		ATTACK:
			pass
		PATROL:
			pass
