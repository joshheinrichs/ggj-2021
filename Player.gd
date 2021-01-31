extends KinematicBody2D

onready var Overlap = $Overlap_Area
onready var animatedSprite = $AnimatedSprite

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
var tree_shape
export var score = 0
var treeInRange = false
var flipped_sprite = false

signal found_bug

func _physics_process(delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	move_vec.y += GRAVITY
		
	if treeInRange == true && Input.is_action_just_pressed("move_up"):
		if flipped_sprite == false:
			rotate_sprite()
		move_vec.x = 0
		check_tree_side()
		state = CLIMB_TREE

	match state:
		IDLE:
			pass
		RUNNING:
			animatedSprite.flip_v = false
			animatedSprite.flip_h = move_vec.x < 0
			
			move_vec.x -= (move_vec.x * DECEL * delta)
					
			if direction != Vector2.ZERO:
				animatedSprite.play("run")
				
				if move_vec.x > MAX_SPEED:
					move_vec.x = MAX_SPEED
				elif move_vec.x < -MAX_SPEED:
					move_vec.x = -MAX_SPEED
				else:
					move_vec.x += (direction.x * ACCEL * delta)
			else:
				animatedSprite.play("idle")
				
			if is_on_floor() and Input.is_action_just_pressed("jump"):
				animatedSprite.play("glide")
				move_vec.y = JUMP
			
			if !is_on_floor():
				animatedSprite.play("glide")
			
#			if Input.is_action_pressed("jump") and move_vec.y > GLIDE:
#				move_vec.y = GLIDE
				
		CLIMB_TREE:

			if direction != Vector2.ZERO:
				animatedSprite.play("run")
				animatedSprite.flip_h = move_vec.y < 0
				
				if self.position.x < tree_shape.position.x:
					animatedSprite.flip_v = true
				else:
					animatedSprite.flip_v = false
					
				move_vec.y = direction.y * MAX_SPEED
			else:
				animatedSprite.play("idle")
				move_vec.y = 0

			if Input.is_action_just_pressed("jump"):
				move_vec.y = JUMP
				move_vec.x = MAX_SPEED * direction.x
				state = RUNNING
						
	move_vec = move_and_slide(move_vec, UP)
			
func _on_Overlap_Area_area_entered(area):
	if area.is_in_group("Food"):
		emit_signal("found_bug")
		area.queue_free()
		
	elif area.name == "Tree" or area.get_parent().name == "Trees":
		treeInRange = true
		tree_shape = area

func _on_Overlap_Area_area_exited(area):
	treeInRange = false
	if flipped_sprite == true:
		rotate_sprite()
	state = RUNNING
	

func rotate_sprite():
	if flipped_sprite == false:
		animatedSprite.rotate(deg2rad(90))
		flipped_sprite = true
	else:
		animatedSprite.rotate(deg2rad(-90))
		flipped_sprite = false

func check_tree_side():		
	if self.position.x < tree_shape.position.x:
		self.position.x = tree_shape.position.x - (tree_shape.get_child(0).shape.extents.x)
		
	if self.position.x > tree_shape.position.x:
		self.position.x = tree_shape.position.x + (tree_shape.get_child(0).shape.extents.x)


