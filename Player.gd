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
const ACCEL = 3000
const DECEL = 10
const GRAVITY = 25
const JUMP = -650
const GLIDE = 50

var move_vec = Vector2.ZERO
var current_area
export var score = 0
var treeInRange = false

signal found_bug

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
			move_vec.x -= (move_vec.x * DECEL * delta)

			if direction != Vector2.ZERO:
				if move_vec.x > MAX_SPEED:
					move_vec.x = MAX_SPEED
				elif move_vec.x < -MAX_SPEED:
					move_vec.x = -MAX_SPEED
				else:
					move_vec.x += (direction.x * ACCEL * delta)
			
			if is_on_floor() and Input.is_action_just_pressed("jump"):
				move_vec.y = JUMP
			
			if Input.is_action_pressed("jump") and move_vec.y > GLIDE:
				move_vec.y = GLIDE
				
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
	if area.name == "Bug" or area.get_parent().name == "Bugs":
		emit_signal("found_bug")
		# TODO: is there a better way to remove food?
		area.get_parent().remove_child(area)
	elif area.name == "Tree" or area.get_parent().name == "Trees":
		treeInRange = true
		current_area = area
		# holding up when you enter the tree
		if Input.is_action_pressed("move_up"):
			state = CLIMB_TREE

func _on_Overlap_Area_area_exited(area):
	treeInRange = false
	state = RUNNING



