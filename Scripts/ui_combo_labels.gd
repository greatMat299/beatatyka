extends Control

var playerCount=0
var prevCombo=0
var players=[]
var activeLabels=[]

func _ready():
	#dodawanie elementów graczy oraz tekstów z graczami
	await get_tree().process_frame
	playerCount=GameManager.player_count
	get_parent().get_node("BeatCatcher").beatAttacked.connect(self._on_beat_attacked)
	for i in range(0,playerCount):
		players.push_back(get_parent().get_parent().get_parent().get_node(str("Player")+str(i+1)))
		activeLabels.push_back(self.get_node(str("Label")+str(i+1)))
	#print(players)
	
	
func _on_beat_attacked(index,type,comboAmount):
	activeLabels[index-1].visible=true
	if type==0 and prevCombo>0:
		activeLabels[index-1].text = "MISS!"
		prevCombo=0
	elif type>0:
		match type:
			1:
				activeLabels[index-1].text = "GOOD "+str(comboAmount)+"x"
			2:
				activeLabels[index-1].text = "GREAT "+str(comboAmount)+"x"
			4:
				activeLabels[index-1].text = "PERFECT "+str(comboAmount)+"x"
	if type>0:
		prevCombo+=1
	await get_tree().create_timer(1.0).timeout
	activeLabels[index-1].visible=false
