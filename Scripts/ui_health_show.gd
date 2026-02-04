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
	print(players)
	
func _process(_delta):
	#sprawdzamy czy są jakieś elementy w tablicy
	if len(activeLabels)>0:
		activeLabels[0].text=str("Player 1: ")+str(players[0].get_node("HealthManager").health)
		if playerCount==2:
			activeLabels[1].text=str("Player 2: ")+str(players[1].get_node("HealthManager").health)
		if playerCount==3:
			activeLabels[2].text=str("Player 3: ")+str(players[2].get_node("HealthManager").health)
		if playerCount==4:
			activeLabels[3].text=str("Player 4: ")+str(players[3].get_node("HealthManager").health)
