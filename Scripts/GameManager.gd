extends Node

var currentNote=0
var isGamePlaying=true
var platformsList=[]
var platformPrevList=[]
var spikeList=[]
var mapName="Map1"

func searchForPlatforms():
	for i in range(1,6):
		var platformNode = get_parent().get_node(mapName).get_node(str("Platforms")+str(i))
		print(platformNode)
		platformsList.push_back(platformNode)
	for i in range(1,6):
		var platformPrevNode = get_parent().get_node(mapName).get_node(str("Platforms")+str(i)+str("Prev"))
		print(platformPrevNode)
		platformPrevList.push_back(platformPrevNode)
	print(platformsList)
	
func searchForSpikes():
	for i in range(1,3):
		var spikeNode = get_parent().get_node(mapName).get_node(str("Spikes")+str(i))
		print(spikeNode)
		spikeList.push_back(spikeNode)
	print(spikeList)
		
