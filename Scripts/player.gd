extends CharacterBody2D

signal playerAttack(player, damage, playerDamaged)

const SPEED = 250.0
const JUMP_VELOCITY = -500.0
const PLAYER_ACTIONS = ["jump", "right", "left", "attack", "block"]
var jumps=0
var maxJumps = 1
var dashPresses=0
var maxDashPresses=1
var dashVelocity := 0.0
var player_id := -1
var currentPlayerActions = []
@onready var animSprite = $AnimatedSprite2D
@onready var moveTimer = $MoveTimer
@onready var bufferTimer = $BufferTimer
@onready var dashPressTimer = $DashPressTimer
@onready var attackRaycast = $AttackRaycast
@onready var dashRaycast = $DashRaycast
@onready var dashCooldownTimer = $DashCooldownTimer
@onready var dashAttackCooldownTimer = $DashAttackCooldownTimer
@export var maxBufferTime : float = 0.15
@export var maxDashPressTime : float = 0.15
@export var dashPower : float = 1000.0
@export var dashCooldownAmount : float = .5
@export var attackPower : float = 15.0
@export var dashAttackPower : float = 30.0

func _ready():
	bufferTimer.wait_time = maxBufferTime
	dashPressTimer.wait_time = maxDashPressTime
	player_id = GameManager.register_player()
	dashCooldownTimer.wait_time = dashCooldownAmount
	#print("I am player", player_id)
	for i in range(0,len(PLAYER_ACTIONS)):
		currentPlayerActions.push_back(str("player")+str(player_id)+str("_")+str(PLAYER_ACTIONS[i]))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if GameManager.arePlayersAlive[player_id-1]==true:
		if animSprite.flip_h==true:
			attackRaycast.target_position.y = -15
			dashRaycast.target_position.y = -40
		else:
			attackRaycast.target_position.y = 15
			dashRaycast.target_position.y = 40
		#print(dashCooldownTimer.time_left)
		
		var direction = Input.get_axis(currentPlayerActions[2], currentPlayerActions[1])
		
		
			
		#funkcje ataku i dash'a
		if Input.is_action_just_pressed(currentPlayerActions[3]):
			dashPressTimer.start()
			if attackRaycast.is_colliding():
				var body = attackRaycast.get_collider()
				emit_signal("playerAttack",player_id,attackPower,body)
			if dashPresses < maxDashPresses:
				dashPresses += 1
			else:
				if dashCooldownTimer.time_left > 0.0:
					pass
				else:
					dashVelocity = dashPower * direction
				dashPresses=0
				dashPressTimer.stop()
				
		if dashRaycast.is_colliding():
			if abs(velocity.x)>SPEED and dashAttackCooldownTimer.time_left<=0:
				dashAttackCooldownTimer.start()
				var body = dashRaycast.get_collider()
				emit_signal("playerAttack",player_id,dashAttackPower,body)
				dashCooldownTimer.start()


		# Handle dash.
		if Input.is_action_just_pressed(currentPlayerActions[0]):
			bufferTimer.start()
			if jumps < maxJumps:
				print("yump")
				jumps += 1
				velocity.y = JUMP_VELOCITY
			
			
		#resetowanie skoków jeżeli gracz jest na ziemi
		if is_on_floor():
			jumps = 0	
			if bufferTimer.time_left>0:
				jumps += 1
				velocity.y = JUMP_VELOCITY
				bufferTimer.stop()

		dashVelocity = move_toward(dashVelocity, 0, dashPower * delta * 6)

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if direction:
			if moveTimer.is_stopped()==false and GameManager.arePlayersAlive[player_id-1]==false:
				moveTimer.stop()
			velocity.x = (direction * SPEED) + dashVelocity
			animSprite.play("walk")
			if direction==-1:
				animSprite.flip_h=true
			else:
				animSprite.flip_h=false
		else:
			if moveTimer.is_stopped()==true and GameManager.arePlayersAlive[player_id-1]==true:
				moveTimer.start()
			animSprite.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
	else:
		animSprite.stop()
		set_collision_layer_value(2,false)
		set_collision_mask_value(1,false)
		animSprite.self_modulate=Color(1,1,1,.4)

#zakończenie gry po spadnięciu z mapy
func _on_death_area_body_entered(body: Node2D) -> void:
	print("DEATH")
	moveTimer.stop()
	GameManager.isGamePlaying = false
	


func _on_move_timer_timeout():
	#GameManager.isGamePlaying=false
	pass


func _on_dash_press_timer_timeout():
	pass

#rzeczy po zrobieniu damage'a przez gracza
func _on_player_attack(player, damage, playerDamaged):
	print(str("Player ")+str(player)+str(" did ")+str(damage)+str(" damage")+str(" to ")+str(playerDamaged.name))
