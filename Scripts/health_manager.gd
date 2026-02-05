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
	if health<=0 and GameManager.arePlayersAlive[id-1]==true:
		get_parent().get_node("SFX").get_node("DeathSfx").play()
		GameManager.arePlayersAlive[id-1]=false
		GameManager.player_count-=1
		health=0
		pass

func _on_player_attack(player, damage, playerDamaged, direction):
	print(str("helo ")+str(playerDamaged))
	playerDamaged.get_node("HealthManager").health-=damage
	#print(playerDamaged.get_node("HealthManager").health)
