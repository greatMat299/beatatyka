extends Node

var currentNote=0
var isGamePlaying=true
var platformsList=[]
var spikeList=[]
var mapName="Map1"

func searchForPlatforms():
	for i in range(1,5):
		var platformNode = get_parent().get_node(mapName).get_node(str("Platforms")+str(i))
		print(platformNode)
		platformsList.push_back(platformNode)
	print(platformsList)
	
func searchForSpikes():
	for i in range(1,3):
		var spikeNode = get_parent().get_node(mapName).get_node(str("Spikes")+str(i))
		print(spikeNode)
		spikeList.push_back(spikeNode)
	print(spikeList)
		
