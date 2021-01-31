extends KinematicBody2D
enum {
	WAIT
	ATTACK
	PATROL
	MOVE
}
const UP = Vector2(0,-1)
const SPEED = 200
const MAX_SPEED = 4
const RANGE = 100

var state = WAIT
var sightAngle = 0
var rayPoints = [Vector2.ZERO,Vector2.ZERO]
var playerFound = false
var prey = null
var preyVec = Vector2.ZERO
var move = false
var targetVec = Vector2.ZERO
var targetBranch

func _on_Timer_timeout():
	print("triggered")
	move = true

func _ready():
	var rayPoints = [get_node("RayCast2D").position,get_node("RayCast2D").cast_to]
	get_node("waitTimer").start(3)

func _process(delta):
	match state:
		WAIT:
			#start ray and beam
			get_node("Line2D").visible = true
			get_node("RayCast2D").enabled = true
			#rotation of ray
			sightAngle += deg2rad(1)
			get_node("RayCast2D").cast_to = Vector2(cos(sightAngle)*RANGE,sin(sightAngle)*RANGE)
			#match the red line to the ray trace
			rayPoints = [get_node("RayCast2D").position,get_node("RayCast2D").cast_to]
			get_node("Line2D").points = rayPoints
			if get_node("RayCast2D").is_colliding() == true:
					if get_node("RayCast2D").get_collider().name == "Player":
							prey = get_node("RayCast2D").get_collider()
					state = ATTACK
			if move == true:
				state = PATROL
				move = false
				var owlBranches = get_tree().get_nodes_in_group("owlBranchGroup")
				owlBranches.shuffle()
				targetBranch = owlBranches[0]
				targetVec = (targetBranch.position-self.position).normalized() * SPEED
		ATTACK:
			get_node("Line2D").visible = false
			get_node("RayCast2D").enabled = false
			preyVec = (prey.position-self.position).normalized() * SPEED
			preyVec += move_and_slide(preyVec, UP)
		PATROL:
			move_and_slide(targetVec,UP)
			for thing in $Area2D.get_overlapping_areas():
				if thing != null:
					if "owlBranch" in thing.name:
						targetVec = Vector2.ZERO
						#self.Position = thing.Position
						state = WAIT
						$waitTimer.start(3)
