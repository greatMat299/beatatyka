extends CharacterBody2D

signal playerAttack(player, damage, playerDamaged, direction)

const SPEED = 250.0
const JUMP_VELOCITY = -500.0
const PLAYER_ACTIONS = ["jump", "right", "left", "attack", "block"]
var jumps=0
var maxJumps = 1
var dashPresses=0
var maxDashPresses=1
var dashVelocity := 0.0
var player_id := -1
var attackVelocity := 0.0
var currentPlayerActions = []
var input_velocity := 0.0
var attacking = false
var blocking = false
var isPlayerInBlockArea=false
var playerAttacking=""
var isInvincible=false

var powerup1
var powerup2
var powerup3

@onready var animSprite = $AnimatedSprite2D
@onready var moveTimer = $MoveTimer
@onready var bufferTimer = $BufferTimer
@onready var dashPressTimer = $DashPressTimer
@onready var attackRaycast = $AttackRaycast
@onready var dashRaycast = $DashRaycast
@onready var dashCooldownTimer = $DashCooldownTimer
@onready var dashAttackCooldownTimer = $DashAttackCooldownTimer
@onready var attackCooldownTimer = $AttackCooldownTimer
@onready var blockTimer = $BlockTimer
@onready var blockCooldownTimer = $BlockCooldownTimer
@onready var dashSfx = $SFX/DashSfx
@onready var attackSfx = $SFX/AttackSfx
@onready var walkSfx = $SFX/WalkSfx
@onready var jumpSfx = $SFX/JumpSfx
@onready var blockSfx = $SFX/BlockSfx

@export_category("Timer Lengths")
@export var maxBufferTime : float = 0.15
@export var maxDashPressTime : float = .3
@export var dashCooldownAmount : float = .7
@export var attackCooldownAmount : float = .3
@export var blockTimeAmount : float = .7
@export var blockCooldownAmount : float = 3.0

@export_category("Attribute power values")
@export var dashPower : float = 1000.0
@export var attackPower : float = 15.0
@export var dashAttackPower : float = 30.0
@export var attackPushPower : float = 600.0


func _ready():
	powerup1 = self.get_parent().get_node("Powerup1")
	powerup2 = self.get_parent().get_node("Powerup2")
	powerup3 = self.get_parent().get_node("Powerup3")
	
	powerup1.set_invicibility.connect(self.set_invicibility)
	powerup2.set_invicibility.connect(self.set_invicibility)
	powerup3.set_invicibility.connect(self.set_invicibility)
	
	print(powerup2)
	
	bufferTimer.wait_time = maxBufferTime
	dashPressTimer.wait_time = maxDashPressTime
	player_id = GameManager.register_player()
	dashCooldownTimer.wait_time = dashCooldownAmount
	attackCooldownTimer.wait_time = attackCooldownAmount
	blockTimer.wait_time = blockTimeAmount
	blockCooldownTimer.wait_time = blockCooldownAmount
	for i in range(0,len(PLAYER_ACTIONS)):
		currentPlayerActions.push_back(str("player")+str(player_id)+str("_")+str(PLAYER_ACTIONS[i]))
	attackRaycast.add_exception(self)
	dashRaycast.add_exception(self)
	
func set_invicibility(body, state):
	if self!=body:
		pass
	else:
		print(str("INVINCIBLE!!! ")+str(state))
		isInvincible=state


func _physics_process(delta):
	print(isInvincible)
	#grawitacja
	if not is_on_floor():
		velocity += get_gravity() * delta
		walkSfx.stop()
		
	#sprawdzanie nazwy tilemalayer'u
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)

			if collision.get_normal().dot(Vector2.UP) > 0.9:
				var collider = collision.get_collider()

				if "Spikes" in collider.name:
					#get_node("HealthManager").health = 0
					pass

	#cała akcja z graczem jeżeli przynajmniej 2 graczy jest żywych
	if GameManager.arePlayersAlive[player_id-1]==true:
		
		#zmiana kierunku animacji postaci
		if animSprite.flip_h==true:
			attackRaycast.target_position.y = -15
			dashRaycast.target_position.y = -25
		else:
			attackRaycast.target_position.y = 15
			dashRaycast.target_position.y = 25
		
		#kierunek ruchu postaci
		var direction = Input.get_axis(currentPlayerActions[2], currentPlayerActions[1])
		
		#zatrzymanie animacji postaci oraz odliczania bez ruchu:
		if GameManager.isGamePlaying==false:
			moveTimer.stop()
			animSprite.stop()
			
		#funkcje ataku i dash'a
		if Input.is_action_just_pressed(currentPlayerActions[3]) and GameManager.isGamePlaying==true:
			dashPressTimer.start()
			var dir = Input.get_axis(currentPlayerActions[2], currentPlayerActions[1])
			if attackRaycast.is_colliding() and attackCooldownTimer.is_stopped() and dir != 0:
				var body = attackRaycast.get_collider()
				if body.blocking:
					body.get_node("AnimationPlayer").play("playerBlock")
					blockSfx.play()
				else:
					if !body.isInvincible:
						attackCooldownTimer.start()
						body.attackVelocity = attackPushPower * sign(dir)
						if body.get_node("AnimationPlayer").is_playing()==false:
							body.get_node("AnimationPlayer").play("playerHurt")
						else:
							body.get_node("AnimationPlayer").stop()
							body.get_node("AnimationPlayer").play("playerHurt")
						emit_signal("playerAttack",player_id,attackPower,body,dir)
			if dashPresses < maxDashPresses:
				dashPresses += 1
			else:
				if !dashCooldownTimer.is_stopped():
					pass
				else:
					dashSfx.play()
					dashCooldownTimer.start()
					dashVelocity = dashPower * direction
				dashPresses=0
				dashPressTimer.stop()
		
		#anulacja dash'u jeżeli odliczanie się skończy
		if dashPressTimer.is_stopped():
			dashPresses=0
		
		#funkcja zablokowania ataku
		if Input.is_action_just_pressed(currentPlayerActions[4]) and GameManager.isGamePlaying==true:
			if isPlayerInBlockArea==true and blockCooldownTimer.is_stopped():
				print("block")
				blocking=true
				blockTimer.start()
				blockCooldownTimer.start()
				
		#anulowanie zablokowania
		if blockTimer.is_stopped():
			blocking=false
		
		#atak z dash'em
		if dashRaycast.is_colliding():
			if abs(velocity.x)>700.0 and dashAttackCooldownTimer.is_stopped():
				dashAttackCooldownTimer.start()
				var body = dashRaycast.get_collider()
				var hit_dir := -1 if animSprite.flip_h else 1
				body.attackVelocity = attackPushPower * hit_dir
				emit_signal("playerAttack",player_id,dashAttackPower,body,direction)
				dashCooldownTimer.start()


		#aktywacja dash'a
		if Input.is_action_just_pressed(currentPlayerActions[0]) and GameManager.isGamePlaying==true:
			bufferTimer.start()
			if jumps < maxJumps:
				print("yump")
				jumpSfx.play()
				jumps += 1
				velocity.y = JUMP_VELOCITY
			
			
		#resetowanie skoków na buffer jeżeli gracz jest na ziemi
		if is_on_floor() and GameManager.isGamePlaying==true:
			jumps = 0	
			if bufferTimer.time_left>0:
				jumps += 1
				jumpSfx.play()
				velocity.y = JUMP_VELOCITY
				bufferTimer.stop()

		#zmienne z dash'em i atakowaniem z dash'em
		dashVelocity = move_toward(dashVelocity, 0, dashPower * delta * 6)
		attackVelocity = move_toward(attackVelocity, 0, 4000 * delta)

		#podstawowy ruch gracza
		if direction and GameManager.isGamePlaying==true:
			input_velocity = direction * SPEED
			var external_velocity := dashVelocity + attackVelocity
			if moveTimer.is_stopped()==false and GameManager.arePlayersAlive[player_id-1]==true:
				moveTimer.stop()
			if abs(external_velocity) > 1.0:
				velocity.x = (direction * SPEED) + dashVelocity
			else:
				velocity.x = move_toward(velocity.x, input_velocity, SPEED)
			animSprite.play("walk")
			if walkSfx.playing==false and is_on_floor():
				walkSfx.play()
			if direction==-1:
				animSprite.flip_h=true
			else:
				animSprite.flip_h=false
		else:
			if moveTimer.is_stopped()==true and GameManager.arePlayersAlive[player_id-1]==true:
				moveTimer.start()
			animSprite.play("idle")
			walkSfx.stop()
			if abs(attackVelocity) > 1.0:
				velocity.x = attackVelocity
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		
	#akcje po śmierci wszystkich oprócz jednego gracza
	else:
		animSprite.stop()
		set_collision_layer_value(2,false)
		set_collision_mask_value(1,false)
		animSprite.self_modulate=Color(1,1,1,.4)

#zakończenie gry po spadnięciu z mapy
func _on_death_area_body_entered(body: Node2D) -> void:
	print("DEATH")
	moveTimer.stop()
	body.get_node("HealthManager").health=0

#funkcje po upłynięciu odliczania na ruch grazca
func _on_move_timer_timeout():
	#if velocity.x == 0 and is_on_floor():
		#get_node("HealthManager").health = 0
	pass

#rzeczy po zrobieniu damage'a przez gracza
func _on_player_attack(player, damage, playerDamaged, direction):
	if !playerDamaged.isInvincible:
		print("gets throug")
		attackSfx.play()
		attacking=true
		GameManager.playerAttackStatus[player_id-1]=attacking
		await get_tree().create_timer(.9).timeout
		attacking=false
		GameManager.playerAttackStatus[player_id-1]=attacking
		print(str("Player ")+str(player)+str(" did ")+str(damage)+str(" damage")+str(" to ")+str(playerDamaged.name))


func _on_dash_cooldown_timer_timeout():
	print("COOLDOWN")

#kiedy inny gracz wejdzie w strefę "blocku" gracza
func _on_block_area_body_entered(body):
	if body!=self:
		playerAttacking=body.player_id
		isPlayerInBlockArea=true
		print(str(body.name)+str(" ")+str(player_id))
