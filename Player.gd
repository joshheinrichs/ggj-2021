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
const GRAVITY = 2000
const JUMP = -650
const GLIDE_ACCEL = 750

var move_vec = Vector2.ZERO
var tree_shape
export var score = 0
var treeInRange = false
var flipped_sprite = false
var alive = true

signal found_bug
signal killed

func _physics_process(delta):
	if $"/root/Globals".play == false:
		return
	if not alive:
		return

	var direction = Vector2.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	move_vec.y += GRAVITY * delta
		
	if state == RUNNING and treeInRange == true && Input.is_action_pressed("move_up") and move_vec.y > 0:
		move_vec.x = 0
		check_tree_side()
		state = CLIMB_TREE
		$treeMove.play()

	if state == CLIMB_TREE:
		animatedSprite.rotation = deg2rad(90)
	else:
		animatedSprite.rotation = deg2rad(0)

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
				$jump.play()
				animatedSprite.play("glide")
				move_vec.y = JUMP
				state = RUNNING
			
			if !is_on_floor():
				animatedSprite.play("glide")
			
			if not is_on_floor() and Input.is_action_pressed("jump"):
				move_vec.y -= GLIDE_ACCEL * delta

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
			
			if is_on_floor():
				state = RUNNING

			if Input.is_action_just_pressed("jump"):
				$jump.play()
				move_vec.y = JUMP
				move_vec.x = MAX_SPEED * direction.x
				state = RUNNING
						
	move_vec = move_and_slide(move_vec, UP)
			
func _on_Overlap_Area_area_entered(area):
	if not alive:
		return

	if area.is_in_group("Food"):
		emit_signal("found_bug")
		$pickUp.play()
		area.queue_free()
		
	elif area.name == "Tree" or area.get_parent().name == "Trees":
		treeInRange = true
		tree_shape = area

func _on_Overlap_Area_area_exited(area):
	if area.name == "Tree" or area.get_parent().name == "Trees":
		treeInRange = false
		state = RUNNING

func check_tree_side():
	var tree_extents = tree_shape.get_child(0).shape.extents
	if self.position.x < tree_shape.position.x:
		self.position.x = tree_shape.position.x - (tree_extents.x)
	if self.position.x > tree_shape.position.x:
		self.position.x = tree_shape.position.x + (tree_extents.x)

func kill():
	self.alive = false
	emit_signal("killed")
