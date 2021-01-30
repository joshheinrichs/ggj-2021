extends KinematicBody2D

enum {
	WAIT
	ATTACK
	PATROL	
}

const MAX_SPEED = 100
const RANGE = 400

var state = WAIT
var sightAngle = 0
var rayPoints = [Vector2.ZERO,Vector2.ZERO]

func _ready():
	var rayPoints = [get_node("RayCast2D").position,get_node("RayCast2D").cast_to]
	
func _process(delta):
	match state:
		WAIT:
			sightAngle += deg2rad(1)
			get_node("RayCast2D").cast_to = Vector2(cos(sightAngle)*RANGE,sin(sightAngle)*RANGE)
			#match the red line to the ray trace
			rayPoints = [get_node("RayCast2D").position,get_node("RayCast2D").cast_to]
			get_node("Line2D").points = rayPoints
			
		ATTACK:
			pass
		PATROL:
			pass
