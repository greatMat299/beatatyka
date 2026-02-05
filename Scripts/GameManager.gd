extends Node

var currentNote=0
var isGamePlaying=true
var platformsList=[]
var platformPrevList=[]
var spikeList=[]
var spikePrevList=[]
var arePlayersAlive=[]
var playerAttackStatus=[]
var mapName="Map1"
var player_count := 0
var next_player_id := 0

func register_player() -> int:
	arePlayersAlive.push_back(true)
	playerAttackStatus.push_back(false)
	player_count += 1
	next_player_id += 1
	return next_player_id

func searchForPlatforms():
	for i in range(1,6):
		var platformNode = get_parent().get_node(mapName).get_node(str("Platforms")+str(i))
		#print(platformNode)
		platformsList.push_back(platformNode)
	for i in range(1,6):
		var platformPrevNode = get_parent().get_node(mapName).get_node(str("Platforms")+str(i)+str("Prev"))
		#print(platformPrevNode)
		platformPrevList.push_back(platformPrevNode)
	#print(platformsList)
	
func searchForSpikes():
	for i in range(1,3):
		var spikeNode = get_parent().get_node(mapName).get_node(str("Spikes")+str(i))
		#print(spikeNode)
		spikeList.push_back(spikeNode)
	for i in range(1,3):
		var spikePrevNode = get_parent().get_node(mapName).get_node(str("Spikes")+str(i)+str("Prev"))
		#print(spikePrevNode)
		spikePrevList.push_back(spikePrevNode)
	#print(spikeList)
		
