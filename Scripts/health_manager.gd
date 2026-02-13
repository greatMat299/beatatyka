extends Node

var health = 100
var id: int =-1
var powerup1
var powerup2
var powerup3

func _ready():
	powerup1 = self.get_parent().get_parent().get_node("Powerup1")
	powerup2 = self.get_parent().get_parent().get_node("Powerup2")
	powerup3 = self.get_parent().get_parent().get_node("Powerup3")
	
	powerup1.heal_player.connect(self.heal_player)
	powerup2.heal_player.connect(self.heal_player)
	powerup3.heal_player.connect(self.heal_player)
	
	var idString
	idString=get_parent().name
	id=int(idString.substr(len(idString)-1,len(idString)))
	print(id)
	pass
	
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
		get_parent().get_node("SFX").get_node("DeathSfx").play()
		GameManager.arePlayersAlive[id-1]=false
		GameManager.player_count-=1
		health=0

#usuwanie zdrowia zaatakowanemu graczowi
func _on_player_attack(player, damage, playerDamaged, direction):
	print(str("helo ")+str(playerDamaged))
	playerDamaged.get_node("HealthManager").health-=damage
