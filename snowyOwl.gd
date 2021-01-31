extends KinematicBody2D

enum {
	WAIT
	ATTACK
	PATROL
	MOVE
}

export var MAX_VELOCITY = 500
export var MAX_ACCELERATION = 0.5
export var RANGE = 100

var state = WAIT
var sightAngle = 0

var currentBranch
var currentPrey

var caughtPrey = false

var velocity = Vector2.ZERO

func _ready():
	start_wait()

func _on_Timer_timeout():
	if state != WAIT:
		return
	# fly upwards at first to feel more swoopy
	velocity = Vector2.UP * MAX_VELOCITY
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

func move_at_target(target):
	var target_vector = target.position - self.position
	# TODO: the ideal velocity may be shorter than the max velocity
	var ideal_velocity = target_vector.normalized() * MAX_VELOCITY
	
	var acceleration = ideal_velocity - velocity
	if acceleration.length() > MAX_ACCELERATION:
		acceleration = acceleration.normalized() * MAX_ACCELERATION
	velocity += acceleration
	if velocity.length() > MAX_VELOCITY:
		acceleration = acceleration.normalized() * MAX_ACCELERATION

	move_and_slide(velocity)


func _process(delta):
	if caughtPrey:
		currentPrey.position = self.position + Vector2(0, $CollisionShape2D.shape.height)
		# TODO: kinda hacky, should call currentPrey.caught() or something to fix camera jitters
		currentPrey.move_vec = Vector2.ZERO

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
					if not caughtPrey:
						start_attack(prey)
		PATROL:
			$Line2D.visible = false
			$RayCast2D.enabled = false

			move_at_target(currentBranch)

			for thing in $Area2D.get_overlapping_areas():
				if thing == currentBranch:
					velocity = Vector2.ZERO
					start_wait()
		ATTACK:
			$Line2D.visible = true
			$RayCast2D.enabled = false

			var points = [$RayCast2D.position, currentPrey.position - self.position]
			$Line2D.points = points
			
			move_at_target(currentPrey)

			for thing in $Area2D.get_overlapping_areas():
				if thing.get_parent() == currentPrey:
					caughtPrey = true
					# TODO: grab prey
					start_patrol()
