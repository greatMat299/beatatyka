extends Area2D

@onready var animPlayer := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var healSFX = $HealSFX
@onready var gravitySFX = $GravitySFX
@onready var invincibilitySFX = $InvincibilitySFX
@onready var powerupTimer := $PowerupTimer
var powerupTypes=["none","heal","gravity","no_damage"]
var powerupImages=["res://Assets/Images/Powerups/heal.png","res://Assets/Images/Powerups/gravity.png","res://Assets/Images/Powerups/no_damage.png"]
var currentPowerupIndex=-1
var isActive=false
var target_player
var selectedPowerup
var self_id


signal heal_player(player,health)
signal set_invicibility(player,state)

func _ready() -> void:
	#pobranie nazwy powerupa
	self_id=int(name.substr(len(name)-1,len(name)))
	
	#losowanie powerupa oraz jego pozycji
	var rng = RandomNumberGenerator.new()
	selectedPowerup = rng.randi_range(1, 3)
	currentPowerupIndex = rng.randi_range(1, 3)
	print(currentPowerupIndex)
	
	#pobranie tekstury powerupa
	var yourTexture = load(powerupImages[currentPowerupIndex-1])
	animPlayer.play("powerupFloat")
	sprite.texture = yourTexture
	
#wyłączenie powerupa (po jego zabraniu)
func disablePowerup():
	monitoring=false
	get_node("CollisionShape2D").disabled = true
	get_node("Sprite2D").visible=false


func _process(delta: float) -> void:
	if GameManager.currentPowerupIndex!=self_id:
		disablePowerup()	
	#ustawienie domyślnej grawitacji
	var gravity_vector = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR)

func _on_body_entered(body: Node2D) -> void:
	if "Player" in body.name and not isActive:
		target_player=body
		if currentPowerupIndex==1: #powerup leczenia
			emit_signal("heal_player",body,50)
			healSFX.play()
		elif currentPowerupIndex==2: #powerup grawitacji
			isActive=true
			changeGravity()
			powerupTimer.start()
			gravitySFX.play()
		elif currentPowerupIndex==3: #powerup nieszkodliwości
			isActive=true
			emit_signal("set_invicibility",body,true)
			powerupTimer.start()
			invincibilitySFX.play()
		call_deferred("disablePowerup")

#zmiana grawitacji
func changeGravity():
	if isActive:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,.75))
	else:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))

#akcje po zakończeniu działania powerupa
func _on_powerup_timer_timeout() -> void:
	if currentPowerupIndex==2:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))
	elif currentPowerupIndex==3:
		emit_signal("set_invicibility",target_player,false)
	isActive=false
