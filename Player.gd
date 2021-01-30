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
const GRAVITY = 25
const JUMP = -650

var move_vec = Vector2.ZERO
var current_area = Vector2.ZERO

func _physics_process(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	move_vec.y += GRAVITY
	
	match state:
		IDLE:
			pass
		RUNNING:
			if direction != Vector2.ZERO:
				move_vec.x = lerp(0, direction.x * MAX_SPEED, 0.7)	
			else:
				move_vec.x = lerp(move_vec.x, 0, 0.2)
			
			if is_on_floor():
				if Input.is_action_just_pressed("jump"):
					move_vec.y = JUMP
			else:
				move_vec.x = lerp(move_vec.x, 0, 0.05)
				
		CLIMB_TREE:
			move_vec.x = 0
			if direction != Vector2.ZERO:
				move_vec.y = lerp(0, direction.y * MAX_SPEED, 0.7)
			else:
				move_vec.y = lerp(move_vec.y, 0, 1)
			
			if !is_on_floor():
				if Input.is_action_just_pressed("jump"):
					move_vec.y = JUMP
					state = RUNNING
			
			if Input.is_action_just_pressed("move_right"):
				position.x = position.x + current_area.x
			if Input.is_action_just_pressed("move_left"):
				position.x = position.x - current_area.x
				
	move_vec = move_and_slide(move_vec, UP)
			
func _on_Overlap_Area_area_entered(area):
	print("It's " + area.name)
	if Input.is_action_pressed("move_up"):
		state = CLIMB_TREE
		current_area = area.get_child(0).shape.extents
		position.x = area.position.x
		

func _on_Overlap_Area_area_exited(area):
	state = RUNNING