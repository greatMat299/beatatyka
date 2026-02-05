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
	#print(players)
	
func _process(_delta):
	#sprawdzamy czy są jakieś elementy w tablicy
	if len(activeLabels)>0:
		if GameManager.arePlayersAlive[0]==false:
			activeLabels[0].text=str("Player 1: ")+str("DEAD!")
		else:
			activeLabels[0].text=str("Player 1: ")+str(players[0].get_node("HealthManager").health)
		if playerCount==2:
			if GameManager.arePlayersAlive[1]==false:
				activeLabels[1].text=str("Player 2: ")+str("DEAD!")
			else:
				activeLabels[1].text=str("Player 2: ")+str(players[1].get_node("HealthManager").health)
		if playerCount==3:
			if GameManager.arePlayersAlive[2]==false:
				activeLabels[2].text=str("Player 3: ")+str("DEAD!")
			else:
				activeLabels[2].text=str("Player 3: ")+str(players[2].get_node("HealthManager").health)
		if playerCount==4:
			if GameManager.arePlayersAlive[3]==false:
				activeLabels[3].text=str("Player 4: ")+str("DEAD!")
			else:
				activeLabels[3].text=str("Player 4: ")+str(players[3].get_node("HealthManager").health)
