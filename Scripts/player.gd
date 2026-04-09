extends CharacterBody2D

signal playerAttack(player, damage, playerDamaged, direction)

const PLAYER_ACTIONS = ["jump", "right", "left", "attack", "block", "down", "ult"]
var jumps=0
var maxJumps = 1
var jumpAviable = false
var jumpBuffer = false
var dashPresses=0
var maxDashPresses=1
var dashVelocity := 0.0
var player_id : int = -1
var attackVelocity := 0.0
var currentPlayerActions = []
var input_velocity := 0.0
var attacking = false
var blocking = false
var isPlayerInBlockArea=false
var playerAttacking=""
var isInvincible=false
var playerKeybindId=-1
var currentSpriteSheet
var isDashAnim=false
var spikeDMG = 10
var laserDMG = 15
var boomboxUltDMG = 55
var electricGuiterDMGMultiplayer = 2
var canLaserDMG = true
var laserDMGCooldownAmount = 0.3
var should_play := false
var is_crouching :=false
var canUseUlt = true

var powerup1
var powerup2
var powerup3

@onready var animSprite = $AnimatedSprite2D
@onready var chant = get_parent().get_node("CrowdChantSFX")
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
@onready var saxophonePassiveTimer = $SaxophonePassiveTimer
@onready var ultDurationTimer = $UltDurationTimer
@onready var ultCooldownTimer = $UltCooldownTimer
@onready var dashSfx = $SFX/DashSfx
@onready var attackSfx = $SFX/AttackSfx
@onready var classicGuitarAttackSfx = $SFX/ClassicGuitarAttackSfx
@onready var walkSfx = $SFX/WalkSfx
@onready var jumpSfx = $SFX/JumpSfx
@onready var blockSfx = $SFX/BlockSfx
@onready var saxophoneHealSfx = $SFX/SaxophoneHealSfx
@onready var sonicBoomSfx = $SFX/SonicBoomSfx
@onready var invincibilitySfx = $SFX/InvincibilitySfx
@onready var guitarAttackSfx = $SFX/GuitarAttackSfx
@onready var coyoteTimer = $CoyoteTimer
@onready var jumpBufferTimer = $jumpBufferTimer
@onready var laserDMGCooldownTimer = $LaserDMGCooldownTimer
@onready var sonicBoomArea = $SonicBoomArea2D
@onready var playerNumberLabel = $PlayerNumberLabel
@onready var collision_box = $CollisionShape2D
@onready var sonicBoomAnimation = $SonicBoomArea2D/sonicBoomAnimation
@onready var animTimer = $AnimTimer

@export_category("Player attributes")
@export var playerSpeed : float = 250.0
@export var jumpVelocity : float = -500.0

@export_category("Timer Lengths")
@export var maxBufferTime : float = 0.15
@export var maxDashPressTime : float = .3
@export var dashCooldownAmount : float = .7
@export var attackCooldownAmount : float = .3
@export var blockTimeAmount : float = .7
@export var blockCooldownAmount : float = 3.0
@export var coyoteTimerAmount : float = 0.10
@export var jumpBufferTimerAmount : float = 0.15
var ultCooldownTimerAmount : float = 30.0



@export_category("Attribute power values")
@export var dashPower : float = 800.0
@export var attackPower : float = 15.0
@export var dashAttackPower : float = 30.0
@export var attackPushPower : float = 800.0


func _ready():
	
	#inicjacja powerupów
	powerup1 = self.get_parent().get_node("Powerup1")
	powerup2 = self.get_parent().get_node("Powerup2")
	powerup3 = self.get_parent().get_node("Powerup3")
	
	powerup1.set_invicibility.connect(self.set_invicibility)
	powerup2.set_invicibility.connect(self.set_invicibility)
	powerup3.set_invicibility.connect(self.set_invicibility)
	
	animSprite.sprite_frames=currentSpriteSheet
	
	#inicjacja timerów
	bufferTimer.wait_time = maxBufferTime
	dashPressTimer.wait_time = maxDashPressTime
	dashCooldownTimer.wait_time = dashCooldownAmount
	attackCooldownTimer.wait_time = attackCooldownAmount
	blockTimer.wait_time = blockTimeAmount
	blockCooldownTimer.wait_time = blockCooldownAmount
	coyoteTimer.wait_time = coyoteTimerAmount
	jumpBufferTimer.wait_time = jumpBufferTimerAmount
	ultCooldownTimer.wait_time = ultCooldownTimerAmount
	
	var color
	match player_id:
		1: color = Color(0.996, 0.0, 0.176)
		2: color = Color(0.0, 0.557, 0.929)
		3: color = Color(0.267, 0.639, 0.0)
		4: color = Color(0.62, 0.584, 0.075)

	playerNumberLabel.modulate = color
	
	#Wyswietlanie numeru gracza
	playerNumberLabel.text = "P"+str(player_id)
	
	#dodanie przypisów klawiszy dla graczy
	for i in range(0,len(PLAYER_ACTIONS)):
		currentPlayerActions.push_back(str("player")+str(playerKeybindId)+str("_")+str(PLAYER_ACTIONS[i]))
		
	if(ultCooldownTimerAmount == 5): 
		saxophonePassiveTimer.start(ultCooldownTimerAmount)	
	
	#usunięcie swojej kolizji z RayCastów
	attackRaycast.add_exception(self)
	dashRaycast.add_exception(self)
	
func set_invicibility(body, state):
	if self!=body:
		pass
	else:
		isInvincible=state
		if state==true:
			body.get_node("AnimationPlayer").play("invincibilityAnim")
			invincibilitySfx.play()
		else:
			body.get_node("AnimationPlayer").stop()
			invincibilitySfx.stop()



func _physics_process(delta):
	print("ult: ",ultCooldownTimer.time_left)
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
				#print(collider)
				if "SpikeTMLayer" in collider.name:
					get_node("HealthManager").health -= spikeDMG
					Jump()
					pass
					
					
	var health = get_node("HealthManager").health
	var condition = health < 15 and GameManager.player_count == 2 and GameManager.arePlayersAlive[player_id-1]==true

	if condition and !should_play:
		chant.play()
		should_play = true

	elif !condition and should_play:
		chant.stop()
		should_play = false
		
	#kucanie
	if Input.is_action_just_pressed(currentPlayerActions[5]):
		animSprite.position = Vector2(0,1.5)
		playerSpeed = .125*playerSpeed
		collision_box.scale = Vector2(1,0.5)
		collision_box.position = Vector2(0,9)
		is_crouching = true
	
	if Input.is_action_just_released(currentPlayerActions[5]):
		animSprite.position = Vector2(0,0)
		animSprite.skew = 0
		playerSpeed = 8*playerSpeed
		is_crouching = false	
		collision_box.scale =Vector2(1,1)
		collision_box.position = Vector2(0,4)
	if is_crouching:
		animSprite.skew = -.45 if animSprite.flip_h else .45	
					

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
						if is_on_wall():
							velocity.x += sign(velocity.x) * 50
						if player_id > body.player_id:
							body.attackVelocity = attackPushPower * sign(dir)
						if body.get_node("AnimationPlayer").is_playing()==false:
							body.get_node("AnimationPlayer").play("playerHurt")
						else:
							body.get_node("AnimationPlayer").stop()
							body.get_node("AnimationPlayer").play("playerHurt")
						body.emit_signal("playerAttack",player_id,attackPower,body,dir)
			if dashPresses < maxDashPresses:
				dashPresses += 1
			else:
				if !dashCooldownTimer.is_stopped():
					pass
				else:
					dashSfx.play()
					animSprite.stop()
					animSprite.play("dash")
					isDashAnim=true
					dashCooldownTimer.start()
					dashVelocity = dashPower * direction
					await get_tree().create_timer(.2).timeout
					isDashAnim=false
				dashPresses=0
				dashPressTimer.stop()
				
		if Input.is_action_just_pressed(currentPlayerActions[6]) and GameManager.isGamePlaying==true && canUseUlt == true:
			print("tak ",ultCooldownTimerAmount)
			match ultCooldownTimerAmount:
				20.0: 
					electric_guitar_mode()
				30.0:
					sonic_boom_attack()
				10.0:
					guitar_attack()
					
		
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
			if abs(velocity.x)>600.0 and direction != 0 and dashAttackCooldownTimer.is_stopped():	
				dashAttackCooldownTimer.start()
				var body = dashRaycast.get_collider()
				var hit_dir := -1 if animSprite.flip_h else 1
				print("daaash ",body.player_id," ",player_id)
				body.attackVelocity = attackPushPower * hit_dir
				body.emit_signal("playerAttack",player_id,dashAttackPower,body,direction)
				dashCooldownTimer.start()


		#aktywacja dash'a
		#if Input.is_action_just_pressed(currentPlayerActions[0]) and GameManager.isGamePlaying==true:
			#bufferTimer.start()
			#if jumps < maxJumps:
				#print("yump")
				#jumpSfx.play()
				#jumps += 1
				#velocity.y = jumpVelocity
			
			
		
		
		#coyote time
		if !is_on_floor() and GameManager.isGamePlaying==true:
			if jumpAviable == true:
				if coyoteTimer.is_stopped():
					coyoteTimer.start(coyoteTimerAmount)
					print("Start")
		else:
			jumpAviable = true
			coyoteTimer.stop()
		
		
		#mechanika oraz bufferowanie skoku
		if jumpBuffer == true && is_on_floor():
			Jump()
			
		if Input.is_action_just_pressed(currentPlayerActions[0]) && GameManager.isGamePlaying==true:
			if jumpAviable:
				Jump()
			else:
				jumpBuffer = true
				jumpBufferTimer.start()
			#jumps = 0	
			#if bufferTimer.time_left>0:
				#jumps += 1
				#jumpSfx.play()
				#velocity.y = jumpVelocity
				#bufferTimer.stop()
			
		
			
		
		
		#zmienne z dash'em i atakowaniem z dash'em
		dashVelocity = move_toward(dashVelocity, 0, dashPower * delta * 6)
		attackVelocity = move_toward(attackVelocity, 0, 4000 * delta)

		#podstawowy ruch gracza
		if direction and GameManager.isGamePlaying==true:
			if moveTimer.is_stopped()==false and GameManager.arePlayersAlive[player_id-1]==true:
				moveTimer.stop()
			input_velocity = direction * playerSpeed
			var external_velocity := dashVelocity + attackVelocity
			
			if abs(external_velocity) > 1.0:
				velocity.x = (direction * playerSpeed) + dashVelocity
			else:
				velocity.x = move_toward(velocity.x, input_velocity, playerSpeed)
			if isDashAnim==false:
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
			if isDashAnim==false:
				animSprite.play("idle")
			walkSfx.stop()
			if abs(attackVelocity) > 1.0:
				velocity.x = attackVelocity
			else:
				velocity.x = move_toward(velocity.x, 0, playerSpeed)
		move_and_slide()
		
	#akcje po śmierci wszystkich oprócz jednego gracza
	else:
		#moveTimer.stop()
		animSprite.stop()
		stopAllSfx()
		set_collision_layer_value(2,false)
		set_collision_mask_value(1,false)
		animSprite.self_modulate=Color(1,1,1,.4)
		
func stopAllSfx():
	dashSfx.stop()
	attackSfx.stop()
	walkSfx.stop()
	jumpSfx.stop()
	blockSfx.stop()
	invincibilitySfx.stop()

#zakończenie gry po spadnięciu z mapy
func _on_death_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_node("HealthManager"):
		body.get_node("HealthManager").health=0
		moveTimer.stop()

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

func _on_jump_buffer_timer_timeout() -> void:
	jumpBuffer = false
	print("hu hun")

func _on_coyote_timer_timeout() -> void:
	jumpAviable = false
	print("nuh uh")


func Jump():
	print("jump")
	jumpSfx.play()
	velocity.y = jumpVelocity
	jumpAviable = false

# zadawanie obrażeń przez laser (oraz bomby bo mi sie nie chciało)
func take_laser_damage(damage):
	if canLaserDMG == true:
		get_node("HealthManager").health -= damage
		canLaserDMG = false
		laserDMGCooldownTimer.start()

func take_damage(damage):
	if isInvincible == false:
		get_node("HealthManager").health -= damage

func _on_laser_dmg_cooldown_timer_timeout():
	canLaserDMG = true
	
func move_player_to_spawn():
	velocity.x = 0
	velocity.y = 0
	position.x = 50
	position.y = -100
	
func sonic_boom_attack():
	for body in sonicBoomArea.get_overlapping_bodies():
		if "Player" in body.name && body != self:
			body.take_damage(boomboxUltDMG)
	sonicBoomSfx.play()
	ultCooldownTimer.start()
	sonicBoomAnimation.visible = true
	canUseUlt = false
	animTimer.start()
	
#ult od gitary elektrycznej
func electric_guitar_mode():
	attackPower = attackPower * 2
	#ult cooldowny znajdują się w GameManagerze
	ultCooldownTimer.start()
	canUseUlt = false
	modulate = Color(0.0, 0.736, 0.977, 1.0)
	guitarAttackSfx.play()
	await get_tree().create_timer(3.0).timeout
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	attackPower = attackPower / 2
	
func _on_saxophone_passive_timer_timeout():
	take_damage(-2)
	saxophoneHealSfx.play()
	saxophonePassiveTimer.start(ultCooldownTimerAmount)
	
func _on_ult_duration_timer_timeout():
	attackPower = attackPower / 2
	
func _on_ult_cooldown_timer_timeout():
	canUseUlt = true
	
func guitar_attack():
	dashPower = dashPower * 2.5
	dashAttackPower = dashAttackPower * 2
	classicGuitarAttackSfx.play()
	modulate = Color(1.0, 0.51, 0.444, 1.0)
	await get_tree().create_timer(3.0).timeout
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	dashPower = dashPower / 2.5
	dashAttackPower = dashAttackPower / 2
	
	
func _on_anim_timer_timeout():
	sonicBoomAnimation.visible = false
