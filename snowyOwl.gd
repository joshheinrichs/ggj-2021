extends KinematicBody2D

enum {
	WAIT
	ATTACK
	PATROL
	MOVE
}

const SPEED = 200
const MAX_SPEED = 4
const RANGE = 100

var state = WAIT
var sightAngle = 0

var currentBranch
var currentPrey

func _ready():
	start_wait()

func _on_Timer_timeout():
	start_patrol()

func start_wait():
	state = WAIT
	$waitTimer.start(3)

func start_patrol():
		state = PATROL
		var owlBranches = get_tree().get_nodes_in_group("owlBranchGroup")
		owlBranches.shuffle()
		if owlBranches[0] != currentBranch:
			currentBranch = owlBranches[0]
		else:
			currentBranch = owlBranches[1]

func start_attack(prey):
	state = ATTACK
	currentPrey = prey

func _process(delta):
	match state:
		WAIT:
			#start ray and beam
			$Line2D.visible = true
			$RayCast2D.enabled = true

			#rotation of ray
			sightAngle += deg2rad(360 * delta)
			$RayCast2D.cast_to = Vector2(cos(sightAngle)*RANGE, sin(sightAngle)*RANGE)
			#match the red line to the ray trace

			var rayCastPoints = [$RayCast2D.position, $RayCast2D.position + $RayCast2D.cast_to]
			$Line2D.points = rayCastPoints
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider().name == "Player":
					var prey = $RayCast2D.get_collider()
					start_attack(prey)
		PATROL:
			$Line2D.visible = false
			$RayCast2D.enabled = false

			var velocity = (currentBranch.position-self.position).normalized() * SPEED
			move_and_slide(velocity)
			for thing in $Area2D.get_overlapping_areas():
				if thing == currentBranch:
					start_wait()
		ATTACK:
			$Line2D.visible = false
			$RayCast2D.enabled = false

			var velocity = (currentPrey.position-self.position).normalized() * SPEED
			move_and_slide(velocity)
