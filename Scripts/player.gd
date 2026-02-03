extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -500.0
var jumps=0
var maxJumps = 1
@onready var animSprite = $AnimatedSprite2D
@onready var moveTimer = $MoveTimer
@onready var bufferTimer = $BufferTimer
@export var maxBufferTime : float = 0.15

func _ready():
	bufferTimer.wait_time = maxBufferTime
	print(bufferTimer.wait_time)


func _physics_process(delta):	
	#print(bufferTimer.time_left)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player1_jump"):
		bufferTimer.start()
		if jumps < maxJumps:
			print("yump")
			jumps += 1
			velocity.y = JUMP_VELOCITY
			
			
	if is_on_floor():
		jumps = 0
		if bufferTimer.time_left>0:
			jumps += 1
			velocity.y = JUMP_VELOCITY
			bufferTimer.stop()

			

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player1_left", "player1_right")
	if direction:
		if moveTimer.is_stopped()==false and GameManager.isGamePlaying==true:
			moveTimer.stop()
		velocity.x = direction * SPEED
		animSprite.play("walk")
		if direction==-1:
			animSprite.flip_h=true
		else:
			animSprite.flip_h=false
	else:
		if moveTimer.is_stopped()==true and GameManager.isGamePlaying==true:
			moveTimer.start()
		animSprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_death_area_body_entered(body: Node2D) -> void:
	print("DEATH")
	moveTimer.stop()
	GameManager.isGamePlaying = false
	


func _on_move_timer_timeout():
	#GameManager.isGamePlaying=false
	pass
