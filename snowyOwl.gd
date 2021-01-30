extends KinematicBody2D

enum {
	WAIT
	ATTACK
	PATROL	
}
const UP = Vector2(0,-1)
const SPEED = 200
const MAX_SPEED = 4
const RANGE = 400

var state = WAIT
var sightAngle = 0
var rayPoints = [Vector2.ZERO,Vector2.ZERO]
var playerFound = false
var prey = null
var preyVec = Vector2.ZERO


func _ready():
	var rayPoints = [get_node("RayCast2D").position,get_node("RayCast2D").cast_to]
	
func _process(delta):
	match state:
		WAIT:
			get_node("Line2D").visible = true
			get_node("RayCast2D").enabled = true
			sightAngle += deg2rad(1)
			get_node("RayCast2D").cast_to = Vector2(cos(sightAngle)*RANGE,sin(sightAngle)*RANGE)
			#match the red line to the ray trace
			rayPoints = [get_node("RayCast2D").position,get_node("RayCast2D").cast_to]
			get_node("Line2D").points = rayPoints
			if get_node("RayCast2D").is_colliding() == true:
				if get_node("RayCast2D").get_collider().name == "Player":
					prey = get_node("RayCast2D").get_collider()
					state = ATTACK
					
		ATTACK:
			get_node("Line2D").visible = false
			get_node("RayCast2D").enabled = false
			preyVec = (prey.position-self.position).normalized() * SPEED
			preyVec += move_and_slide(preyVec, UP)
		PATROL:
			pass



