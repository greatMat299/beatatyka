extends Node

var health = 100.0
var id: int =-1
var lifes=3
var powerup1
var powerup2
var powerup3

@onready var deathSFX := $"../SFX/DeathSfx"
@onready var animSprite := $"../AnimatedSprite2D"
@onready var moveTimer := $"../MoveTimer"
@onready var player = $".."

func _ready():
	#inicjacja powerupów
	powerup1 = self.get_parent().get_parent().get_node("Powerup1")
	powerup2 = self.get_parent().get_parent().get_node("Powerup2")
	powerup3 = self.get_parent().get_parent().get_node("Powerup3")
	
	powerup1.heal_player.connect(self.heal_player)
	powerup2.heal_player.connect(self.heal_player)
	powerup3.heal_player.connect(self.heal_player)
	
	#pobranie nazwy gracza
	var idString
	idString=get_parent().name
	id=int(idString.substr(len(idString)-1,len(idString)))
	print("id: ",id)
	pass
	
#działanie powerupu leczenia
func heal_player(body, healthAdded):
	if get_parent()!=body:
		pass
	else:
		print("healthyyyy")
		var healthPenalty = 100-body.get_node("HealthManager").health
		if healthPenalty>=50:
			healthPenalty=healthAdded
		body.get_node("HealthManager").health+=healthPenalty
	
func _process(_delta):
	#akcje po wyczerpaniu się zdrowia gracza
	if health<=0 and GameManager.arePlayersAlive[id-1]==true:
		if lifes>1:
			health=100
			get_parent().move_player_to_spawn()
			lifes-=1
			GameManager.playerLifes[id-1]=lifes
		else:
			deathSFX.play()
			GameManager.arePlayersAlive[id-1]=false
			GameManager.player_count-=1
			GameManager.playersDeadOrder.append(id)
			health=0
			animSprite.self_modulate=Color(1,1,1,.4)
			animSprite.stop()
			player.get_node("CollisionShape2D").disabled = true

#usuwanie zdrowia zaatakowanemu graczowi
func _on_player_attack(player, damage, playerDamaged, direction):
	print(str("helo ")+str(playerDamaged)+str(' ')+str(player))
	playerDamaged.get_node("HealthManager").health-=damage
	if playerDamaged.get_node("HealthManager").health<=0 and playerDamaged.get_node("MoveTimer").is_stopped()==false:
		playerDamaged.get_node("MoveTimer").stop()
		
