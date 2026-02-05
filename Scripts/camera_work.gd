extends Camera2D

var playerCount=0
var players=[]
var addedZoomX
var addedOffsetY
@export var defaultZoom: float = 2.78
		
func addPlayers():
	for i in range(0,playerCount):
		players.push_back(get_parent().get_node(str("Player")+str(i+1)))
		
func _process(_delta):
	if playerCount>0:
		addedZoomX=defaultZoom-((abs(players[0].position.x)/2000.0+abs(players[1].position.x)/2000.0)/playerCount)
		addedOffsetY=((players[0].position.y-86.0)/500.0)+((players[1].position.y-86.0)/500.0)/playerCount
		print(((players[0].position.y-86.0)/500.0))
		#self.offset.y=addedOffsetY
		self.zoom = Vector2(addedZoomX+addedOffsetY,addedZoomX+addedOffsetY)
	else:
		playerCount=GameManager.player_count
		addPlayers()
		print(str("pp: ")+str(playerCount))
