extends Node

var health = 100
var id: int =-1

func _ready():
	var idString
	idString=get_parent().name
	id=int(idString.substr(len(idString)-1,len(idString)))
	print(id)
	pass
	
func _process(delta):
	print(GameManager.arePlayersAlive)
	if health<=0 and GameManager.arePlayersAlive[id-1]==true:
		GameManager.arePlayersAlive[id-1]=false
		health=0
		pass

func _on_player_attack(player, damage, playerDamaged):
	print(str("helo ")+str(playerDamaged))
	playerDamaged.get_node("HealthManager").health-=damage
	#print(playerDamaged.get_node("HealthManager").health)
