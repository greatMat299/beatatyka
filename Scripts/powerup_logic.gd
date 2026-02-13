extends Area2D

@onready var animPlayer := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var powerupTimer := $PowerupTimer
var powerupTypes=["none","heal","gravity","no_damage"]
var powerupImages=["res://Assets/Images/Powerups/heal.png","res://Assets/Images/Powerups/gravity.png","res://Assets/Images/Powerups/no_damage.png"]
var currentPowerupIndex=-1
var isActive=false

signal heal_player(player,health)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	currentPowerupIndex = rng.randi_range(1, 3)
	print(currentPowerupIndex)
	
	var yourTexture = load(powerupImages[currentPowerupIndex-1])
	animPlayer.play("powerupFloat")
	sprite.texture = yourTexture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR)
	var gravity_vector = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR)
	#print(gravity_vector.y) 

func _on_body_entered(body: Node2D) -> void:
	if isActive:
		emit_signal("heal_player",body,50)
	if "Player" in body.name:
		isActive=true
		changeGravity()
		powerupTimer.start()

func changeGravity():
	if isActive:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,.75))
	else:
		PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))

func _on_powerup_timer_timeout() -> void:
	print("over")
	isActive=false
	PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2(0,2))
	#changeGravity()
