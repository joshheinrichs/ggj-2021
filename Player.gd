extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const JUMP = -600
const MOVE_SPEED = 20
const MAX_SPEED = 0
const DECCEL = 0.9
var move_vec = Vector2()
var leftright = 0

onready var Overlap = $Overlap_Area

func _physics_process(delta):
		
#	if Input.is_action_pressed("move_up"):
#		move_vec.y = -1 * MOVE_SPEED
#	if Input.is_action_pressed("move_down"):
#		move_vec.y = 1 * MOVE_SPEED
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
	
	
	
	
#	var look_vec = get_global_mouse_position() - global_position
#	global_rotation = atan2(look_vec.y, look_vec.x)


func _on_Overlap_Area_area_entered(area):
	print("It works")
