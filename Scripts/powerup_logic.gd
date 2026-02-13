extends Area2D

@onready var animPlayer := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var healSFX = $HealSFX
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_id=int(name.substr(len(name)-1,len(name)))
	var rng = RandomNumberGenerator.new()
	selectedPowerup = rng.randi_range(1, 3)
	currentPowerupIndex = rng.randi_range(1, 3)
	print(currentPowerupIndex)
	
	var yourTexture = load(powerupImages[currentPowerupIndex-1])
	animPlayer.play("powerupFloat")
	sprite.texture = yourTexture
	

func disablePowerup():
	monitoring=false
	get_node("CollisionShape2D").disabled = true
	get_node("Sprite2D").visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.currentPowerupIndex!=self_id:
		disablePowerup()
	#print(PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR)
	var gravity_vector = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR)

func _on_body_entered(body: Node2D) -> void:
	if "Player" in body.name and not isActive:
		target_player=body
		if currentPowerupIndex==1:
			emit_signal("heal_player",body,50)
			healSFX.play()
		elif currentPowerupIndex==2:
			isActive=true
			changeGravity()
			powerupTimer.start()
		elif currentPowerupIndex==3:
			isActive=true
			emit_signal("set_invicibility",body,true)
			powerupTimer.start()
		call_deferred("disablePowerup")

func changeGravity():
	if isActive:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,.75))
	else:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))

func _on_powerup_timer_timeout() -> void:
	print("OVERC")
	if currentPowerupIndex==2:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))
	elif currentPowerupIndex==3:
		emit_signal("set_invicibility",target_player,false)
	isActive=false
