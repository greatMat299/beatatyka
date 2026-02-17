extends Area2D

@onready var animPlayer := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var healSFX = $HealSFX
@onready var gravitySFX = $GravitySFX
@onready var invincibilitySFX = $InvincibilitySFX
@onready var powerupTimer := $PowerupTimer
var powerupCooldown
var powerupTypes=["none","heal","gravity","no_damage"]
var powerupImages=["res://Assets/Images/Powerups/heal.png","res://Assets/Images/Powerups/gravity.png","res://Assets/Images/Powerups/no_damage.png"]
var isActive=false
var target_player
var selectedPowerup
var self_id
var isCooldownLaunched=false
var rng


signal heal_player(player,health)
signal set_invicibility(player,state)

func _ready() -> void:
	#pobranie nazwy powerupa
	self_id=int(name.substr(len(name)-1,len(name)))
	
	rng = RandomNumberGenerator.new()
		
	#poczekanie na mapChanges żeby zmienił index oraz typ powerupa oraz ustawił poprawne powerupy
	await get_tree().process_frame
	print("disable powerups")
	if GameManager.currentPowerupIndex!=self_id:
		disablePowerup(false)
	else:
		selectPowerup()
		
	#inicjalizacja zegara z cooldownem powerupów
	powerupCooldown = get_parent().get_node("PowerupCooldown")
	print(powerupCooldown)
	
func selectPowerup():
	
	#pobranie tekstury powerupa
	var yourTexture = load(powerupImages[GameManager.currentPowerupType-1])
	animPlayer.play("powerupFloat")
	sprite.texture = yourTexture
	
	#włączenie "kolizji" powerupa z graczem
	monitoring = true
	$CollisionShape2D.disabled = false
	$Sprite2D.visible = true
	
	animPlayer.play("powerupAppear")
	
	
#wyłączenie powerupa (po jego zabraniu)
func disablePowerup(launchTimer:bool):
	monitoring = false
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
	isActive = false
	
	if launchTimer==true:
		powerupCooldown.start()
		isCooldownLaunched=true


func _process(_delta: float) -> void:		
	#ustawienie domyślnej grawitacji
	var gravity_vector = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR)

func _on_body_entered(body: Node2D) -> void:
	if "Player" in body.name and not isActive:
		target_player=body
		if GameManager.currentPowerupType==1: #powerup leczenia
			healSFX.play()
			emit_signal("heal_player",body,50)
		elif GameManager.currentPowerupType==2: #powerup grawitacji
			gravitySFX.play()
			isActive=true
			changeGravity()
			powerupTimer.start()
		elif GameManager.currentPowerupType==3: #powerup nieszkodliwości
			invincibilitySFX.play()
			isActive=true
			emit_signal("set_invicibility",body,true)
			powerupTimer.start()
		call_deferred("disablePowerup",true)

#zmiana grawitacji
func changeGravity():
	if isActive:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,.75))
	else:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))

#akcje po zakończeniu działania powerupa
func _on_powerup_timer_timeout() -> void:
	if GameManager.currentPowerupType==2:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))
	elif GameManager.currentPowerupType==3:
		emit_signal("set_invicibility",target_player,false)
	isActive=false


func _on_powerup_cooldown_timeout():
	
	#jeżeli wylosowane w mapChanges miejsce powerupa nie jest równe id tego powerupa to jest usuwane
	if self_id == GameManager.currentPowerupIndex:
		selectPowerup()
	else:
		disablePowerup(false)
			
		
