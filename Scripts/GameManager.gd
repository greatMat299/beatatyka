extends Node

var currentNote=0
var isGamePlaying=true
var platformsList=[]
var platformPrevList=[]
var spikeList=[]
var spikePrevList=[]
var arePlayersAlive=[]
var playerAttackStatus=[]
var mapName=""
var player_count := 0
var next_player_id := 0
var isSongOver=false
var currentPowerupIndex=-1

#rejestracja gracza do tabeli
func register_player() -> int:
	arePlayersAlive.push_back(true)
	playerAttackStatus.push_back(false)
	player_count += 1
	next_player_id += 1
	return next_player_id

#wyszukiwanie platform
func searchForPlatforms():
	if mapName!="":
		
		#normalne
		for i in range(1,6):
			var platformNode = get_parent().get_node(str(mapName)).get_node(str("Platforms")+str(i))
			#print(platformNode)
			platformsList.push_back(platformNode)
			
		#ostrzegawcze
		for i in range(1,6):
			var platformPrevNode = get_parent().get_node(str(mapName)).get_node(str("Platforms")+str(i)+str("Prev"))
			#print(platformPrevNode)
			platformPrevList.push_back(platformPrevNode)
	
func searchForSpikes():
	if mapName!="":
		
		#normalne
		for i in range(1,3):
			var spikeNode = get_parent().get_node(str(mapName)).get_node(str("Spikes")+str(i))
			#print(spikeNode)
			spikeList.push_back(spikeNode)
		
		#ostrzegawcze
		for i in range(1,3):
			var spikePrevNode = get_parent().get_node(str(mapName)).get_node(str("Spikes")+str(i)+str("Prev"))
			#print(spikePrevNode)
			spikePrevList.push_back(spikePrevNode)
		
