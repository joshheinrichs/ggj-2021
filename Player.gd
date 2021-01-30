extends KinematicBody2D

enum{
	IDLE
	RUNNING
	CLIMB_TREE
}

const UP = Vector2(0,-1)
const GRAVITY = 20
const JUMP = -600
const MOVE_SPEED = 20
const MAX_SPEED = 0
const DECCEL = 0.9
const TREE_SPEED = 200
var move_vec = Vector2()
var leftright = 0
var treeInRange = false
var state = RUNNING

onready var Overlap = $Overlap_Area

func _on_Overlap_Area_area_entered(area):
	print("It's " + area.name)
	treeInRange = true

func _on_Overlap_Area_area_exited(area):
	if area.name == "Tree":
		treeInRange = false
		state = RUNNING

func _physics_process(delta):
	match state:
		IDLE:
			pass
		RUNNING:
			if Input.is_action_pressed("move_right") and is_on_floor():
				move_vec.x += 1	* MOVE_SPEED
			elif Input.is_action_pressed("move_left") and is_on_floor():
				move_vec.x -= 1	* MOVE_SPEED
			else:
				if is_on_floor():
					move_vec.x *= DECCEL
			
			#move_vec = move_vec.normalized() * MOVE_SPEED 
			
			move_vec.y += GRAVITY
			
			move_vec = move_and_slide(move_vec, UP)
			
			if is_on_floor() and Input.is_action_just_pressed("jump"):
				move_vec.y = JUMP
				
			if treeInRange == true and (Input.is_action_pressed("move_up") or Input.is_action_pressed("move_up")):
				state = CLIMB_TREE

		CLIMB_TREE:
			move_vec=Vector2.ZERO
			if Input.is_action_pressed("move_up"):
				move_vec.y = -1 * TREE_SPEED
			if Input.is_action_pressed("move_down"):
				move_vec.y = 1 * TREE_SPEED
			if Input.is_action_pressed("move_right"):
				move_vec.x = 1	* TREE_SPEED
			elif Input.is_action_pressed("move_left"):
				move_vec.x = -1	* TREE_SPEED
				
			move_and_collide(move_vec * delta)
	
