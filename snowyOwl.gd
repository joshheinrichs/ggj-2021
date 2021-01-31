extends KinematicBody2D

enum {
	WAIT
	ATTACK
	PATROL
	MOVE
}

export var MAX_VELOCITY = 500
export var MAX_ACCELERATION = 1000
export var RANGE = 100
export var SWEEPS_PER_SECOND = 0.5
export var WAIT_TIME = 5

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
	$waitTimer.start(WAIT_TIME)

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

func move_at_target(target, delta):
	var target_vector = target.position - self.position
	# TODO: the ideal velocity may be shorter than the max velocity
	var ideal_velocity = target_vector.normalized() * MAX_VELOCITY
	
	var acceleration = (ideal_velocity - velocity) / delta
	if acceleration.length() > MAX_ACCELERATION:
		acceleration = acceleration.normalized() * MAX_ACCELERATION
	velocity += acceleration * delta
	if velocity.length() > MAX_VELOCITY:
		velocity = velocity.normalized() * MAX_VELOCITY

	move_and_slide(velocity)

func _process(delta):
	match state:
		WAIT:
			velocity = Vector2.ZERO
			#start ray and beam
			$Line2D.visible = true
			$RayCast2D.enabled = true

			#rotation of ray
			sightAngle += deg2rad(360 * SWEEPS_PER_SECOND * delta)
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

			move_at_target(currentBranch, delta)

			for thing in $Area2D.get_overlapping_areas():
				if thing == currentBranch:
					start_wait()
		ATTACK:
			$Line2D.visible = true
			$RayCast2D.enabled = false

			var points = [$RayCast2D.position, currentPrey.position - self.position]
			$Line2D.points = points

			move_at_target(currentPrey, delta)

			# TODO: could abort attack near target if it comes in too fast or starts the attack while flying away
			var next_position = self.position + velocity * delta
			var missed_target = (currentPrey.position - self.position).length() < (currentPrey.position - next_position).length()
			if missed_target:
				start_patrol()

			for thing in $Area2D.get_overlapping_areas():
				if thing.get_parent() == currentPrey:
					currentPrey.kill()
					caughtPrey = true
					start_patrol()

	if caughtPrey:
		currentPrey.position = self.position + Vector2(0, $CollisionShape2D.shape.height)
