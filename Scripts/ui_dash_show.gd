extends Node

var playerCount=0
var players=[]
var activeLabels=[]

func _ready():
	
	#dodawanie elementów graczy oraz tekstów z graczami
	playerCount=GameManager.player_count
	for i in range(0,playerCount):
		players.push_back(get_parent().get_parent().get_node(str("Player")+str(i+1)))
		activeLabels.push_back(self.get_node(str("Label")+str(i+1)))
		self.get_node(str("Label")+str(i+1)).visible=true
		

func _process(_delta):
	#sprawdzamy czy są jakieś elementy w tablicy
	if len(activeLabels)>0:
		if GameManager.arePlayersAlive[0]==true:
			if players[0].dashCooldownTimer.is_stopped()==false:
				activeLabels[0].visible=true
			else:
				activeLabels[0].visible=false
			activeLabels[0].text=str(str("DASH COOLDOWN! ")+str("%1.2f" % players[0].dashCooldownTimer.time_left))
			if playerCount==2:
				if players[1].dashCooldownTimer.is_stopped()==false:
					activeLabels[1].visible=true
				else:
					activeLabels[1].visible=false
				activeLabels[1].text=str(str("DASH COOLDOWN! ")+str("%1.2f" % players[1].dashCooldownTimer.time_left))
			if playerCount==3:
				if players[2].dashCooldownTimer.is_stopped()==false:
					activeLabels[2].visible=true
				else:
					activeLabels[2].visible=false
				activeLabels[2].text=str(str("DASH COOLDOWN! ")+str("%1.2f" % players[2].dashCooldownTimer.time_left))
			if playerCount==4:
				if players[3].dashCooldownTimer.is_stopped()==false:
					activeLabels[3].visible=true
				else:
					activeLabels[3].visible=false
				activeLabels[3].text=str(str("DASH COOLDOWN! ")+str("%1.2f" % players[3].dashCooldownTimer.time_left))
