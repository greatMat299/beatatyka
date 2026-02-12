extends Camera2D

var playerCount=0
var players=[]
var addedZoomX
var addedOffsetY
var offsetY_beg
var zoomX_beg
@export var defaultZoom: float = 2.78
		
func addPlayers():
	#dodanie wszystkich graczy do tablicy żeby użyć ich do obliczeń
	for i in range(0,playerCount):
		players.push_back(get_parent().get_node(str("Player")+str(i+1)))
		
func _process(_delta):
	#jeżeli gracz nie jest za nisko to dodaje przybliżenie kamery zależne od pozycji wszystkich graczy
	if playerCount>0:
		if players[0].position.y<160:
			offsetY_beg=(players[0].position.y-86.0)/500.0 #pozycja Y
			zoomX_beg=abs(players[0].position.x)/2000.0 #pozycja X
		if playerCount>=2:
			if players[1].position.y<160:
				offsetY_beg+=(players[1].position.y-86.0)/500.0 #pozycja Y
				zoomX_beg+=abs(players[1].position.x)/2000.0 #pozycja X
		if playerCount>=3:
			if players[2].position.y<160:
				offsetY_beg+=(players[2].position.y-86.0)/500.0 #pozycja Y
				zoomX_beg+=abs(players[2].position.x)/2000.0 #pozycja X
		if playerCount>=4:
			if players[3].position.y<160:
				offsetY_beg+=(players[3].position.y-86.0)/500.0 #pozycja Y
				zoomX_beg+=abs(players[3].position.x)/2000.0 #pozycja X
		addedZoomX=defaultZoom-(zoomX_beg/playerCount) #zoom X
		addedOffsetY=offsetY_beg/playerCount #zoom Y
		self.zoom = Vector2(addedZoomX+addedOffsetY,addedZoomX+addedOffsetY)
		print(players[0].position.y)
	else:
		#jeżeli z jakiegoś powodu nie wykryło żadnych graczy to je dodaje
		playerCount=GameManager.player_count
		addPlayers()
