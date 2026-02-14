extends Control

var playerCount=0
var players=[]
var activeLabels=[]
var animPlayers=[]

func _ready():
	#dodawanie elementów graczy oraz tekstów z graczami
	await get_tree().process_frame
	playerCount=GameManager.player_count
	for i in range(0,playerCount):
		players.push_back(get_parent().get_parent().get_parent().get_node(str("Player")+str(i+1)))
		activeLabels.push_back(self.get_node(str("Label")+str(i+1)))
		self.get_node(str("Label")+str(i+1)).visible=true
		animPlayers.push_back(get_node(str("Label")+str(i+1)).get_node("AnimationPlayer"))
	
func _process(_delta):
	
	#sprawdzamy czy są jakieś elementy w tablicy
	if len(activeLabels)>0:
		if players[0].get_node("HealthManager").health>0 and players[0].moveTimer.is_stopped()==false and players[0].moveTimer.time_left<3.0:
			activeLabels[0].visible=true
			if animPlayers[0].is_playing()==false:
				animPlayers[0].play("moveTimerUIBeat")
		else:
			activeLabels[0].visible=false
			animPlayers[0].stop()
		activeLabels[0].text=str(str("MOVE! ")+str("%1.2f" % players[0].moveTimer.time_left))
		if playerCount>=2:
			if players[1].get_node("HealthManager").health>0 and  players[1].moveTimer.is_stopped()==false and players[1].moveTimer.time_left<3.0:
				activeLabels[1].visible=true
				if animPlayers[1].is_playing()==false:
					animPlayers[1].play("moveTimerUIBeat")
			else:
				activeLabels[1].visible=false
				animPlayers[1].stop()
			activeLabels[1].text=str(str("MOVE! ")+str("%1.2f" % players[1].moveTimer.time_left))
		if playerCount>=3:
			if players[2].get_node("HealthManager").health>0 and  players[2].moveTimer.is_stopped()==false and players[2].moveTimer.time_left<3.0:
				activeLabels[2].visible=true
				if animPlayers[2].is_playing()==false:
					animPlayers[2].play("moveTimerUIBeat")
			else:
				activeLabels[2].visible=false
				animPlayers[2].stop()
			activeLabels[2].text=str(str("MOVE! ")+str("%1.2f" % players[2].moveTimer.time_left))
		if playerCount>=4:
			if players[3].get_node("HealthManager").health>0 and  players[3].moveTimer.is_stopped()==false and players[3].moveTimer.time_left<3.0:
				activeLabels[3].visible=true
				if animPlayers[3].is_playing()==false:
					animPlayers[3].play("moveTimerUIBeat")
			else:
				activeLabels[3].visible=false
				animPlayers[3].stop()
			activeLabels[3].text=str(str("MOVE! ")+str("%1.2f" % players[3].moveTimer.time_left))
