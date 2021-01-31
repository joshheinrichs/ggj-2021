@@ -3,12 +3,13 @@ extends KinematicBody2D
enum {
	WAIT
	ATTACK
	PATROL	
	PATROL
	MOVE
}
const UP = Vector2(0,-1)
const SPEED = 200
const MAX_SPEED = 4
const RANGE = 400
const RANGE = 100

var state = WAIT
var sightAngle = 0
@ -17,19 +18,23 @@ var playerFound = false
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
			#start the wait timer
			get_node("waitTimer").set_wait_time(10)
			get_node("waitTimer").start()
			print($waitTimer.time_left)
			#start ray and beam
			get_node("Line2D").visible = true
			get_node("RayCast2D").enabled = true
@ -45,8 +50,13 @@ func _process(delta):
					state = ATTACK
			if move == true:
				state = PATROL
				move == false
			print(get_node("waitTimer").time_left)
				move = false
				var owlBranches = get_tree().get_nodes_in_group("owlBranchGroup")
				owlBranches.shuffle()
				targetBranch = owlBranches[0]
				targetVec = (targetBranch.position-self.position).normalized() * SPEED
				
			
		ATTACK:
			get_node("Line2D").visible = false
			get_node("RayCast2D").enabled = false
@ -54,11 +64,17 @@ func _process(delta):
			preyVec += move_and_slide(preyVec, UP)
		PATROL:
			#find banches
			var owlBranches = get_tree().get_nodes_in_group("owlBranch")
			owlBranches.shuffle()
			var targetBranch = owlBranches[0]
			var targetVec = (targetBranch.position-self.position).normalized() * SPEED
			targetVec += move_and_slide(targetVec,UP)
			move_and_slide(targetVec,UP)
			for thing in $Area2D.get_overlapping_areas():
				if thing != null:
					if "owlBranch" in thing.name:
						targetVec = Vector2.ZERO
						#self.Position = thing.Position
						state = WAIT
						$waitTimer.start(3)
						




