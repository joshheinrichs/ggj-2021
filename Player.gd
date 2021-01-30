extends KinematicBody2D

onready var Overlap = $Overlap_Area

enum{
	IDLE
	RUNNING
	CLIMB_TREE
}

var state = RUNNING

const UP = Vector2(0,-1)
const MAX_SPEED = 350
const ACCEL = 500
const GRAVITY = 25
const JUMP = -650

var move_vec = Vector2.ZERO
var current_area

var treeInRange = false

func _physics_process(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	move_vec.y += GRAVITY
		
	if treeInRange == true && Input.is_action_just_pressed("move_up"):
		move_vec.x = 0
		position.x = current_area.position.x
		state = CLIMB_TREE

	match state:
		IDLE:
			pass
		RUNNING:
			if direction != Vector2.ZERO:
				if abs(move_vec.x) < MAX_SPEED:
					move_vec.x += (direction.x * ACCEL * delta)
				else: 
					move_vec.x = direction.x * MAX_SPEED
				
				print (move_vec)

			else:
				move_vec.x = 0
			
			if is_on_floor():
				if Input.is_action_just_pressed("jump"):
					move_vec.y = JUMP
			else:
				move_vec.x = lerp(move_vec.x, 0, 0.05)
				
		CLIMB_TREE:

			if direction != Vector2.ZERO:
				move_vec.y = direction.y * MAX_SPEED
			else:
				move_vec.y = 0
			
			if !is_on_floor():
				if Input.is_action_just_pressed("jump"):
					move_vec.y = JUMP
					move_vec.x = lerp(0, MAX_SPEED * direction.x, 1)
					state = RUNNING
			
			if Input.is_action_just_pressed("move_right"):
				position.x = position.x + current_area.get_child(0).shape.extents.x
			if Input.is_action_just_pressed("move_left"):
				position.x = position.x - current_area.get_child(0).shape.extents.x
				
	move_vec = move_and_slide(move_vec, UP)
			
func _on_Overlap_Area_area_entered(area):
	treeInRange = true
	current_area = area
		

func _on_Overlap_Area_area_exited(area):
	treeInRange = false
	state = RUNNING
