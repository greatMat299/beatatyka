extends HBoxContainer

var playerCount=0
var players=[]
var activeHealthLabels=[]
var comboLabels=[]
var prevCombo = 0

@export var playerIcons : Array[Texture2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Player1.hide()
	$Player2.hide()
	$Player3.hide()
	$Player4.hide()
	
	await get_tree().process_frame
	get_parent().get_node("BeatCatcher").beatAttacked.connect(self._on_beat_attacked)
	playerCount=GameManager.player_count
	for i in range(0,playerCount):
		players.push_back(get_parent().get_parent().get_parent().get_node(str("Player")+str(i+1)))
		activeHealthLabels.push_back(self.get_node(str("Player")+str(i+1)+str("/LabelHealth")))
		comboLabels.push_back(self.get_node(str("Player")+str(i+1)+str("/LabelCombo")))
		self.get_node(str("Player")+str(i+1)+str("/LabelHealth")).visible = true
		self.get_node(str("Player")+str(i+1)+str("/LabelCombo")).visible = true
		self.get_node(str("Player")+str(i+1)).show()
		print(GameManager.playerSpriteSheets[0])
		self.get_node(str("Player")+str(i+1)).get_node("PlayerIcon").texture = GameManager.playerSpriteIcons[i]
		
	


func healthChanges():
	if len(activeHealthLabels)>0:
		if GameManager.arePlayersAlive[0]==false:
			activeHealthLabels[0].add_theme_color_override("font_color", Color.RED)
			activeHealthLabels[0].text=str("DEAD!")
		else:
			activeHealthLabels[0].text=str(players[0].get_node("HealthManager").health)
		if playerCount>=2:
			if GameManager.arePlayersAlive[1]==false:
				activeHealthLabels[1].add_theme_color_override("font_color", Color.RED)
				activeHealthLabels[1].text=str("DEAD!")
			else:
				activeHealthLabels[1].text=str(players[1].get_node("HealthManager").health)
		if playerCount>=3:
			if GameManager.arePlayersAlive[2]==false:
				activeHealthLabels[2].add_theme_color_override("font_color", Color.RED)
				activeHealthLabels[2].text=str("DEAD!")
			else:
				activeHealthLabels[2].text=str(players[2].get_node("HealthManager").health)
		if playerCount>=4:
			if GameManager.arePlayersAlive[3]==false:
				activeHealthLabels[3].add_theme_color_override("font_color", Color.RED)
				activeHealthLabels[3].text=str("DEAD!")
			else:
				activeHealthLabels[3].text=str(players[3].get_node("HealthManager").health)

func _on_beat_attacked(index,type,comboAmount):
	comboLabels[index-1].visible=true
	if type==0 and prevCombo>0:
		comboLabels[index-1].add_theme_color_override("font_color", Color.RED)
		comboLabels[index-1].text = "MISS!"
		prevCombo=0
	elif type>0:
		match type:
			1:
				comboLabels[index-1].add_theme_color_override("font_color", Color.BLUE)
				comboLabels[index-1].text = "GOOD "+str(comboAmount)+"x"
			2:
				comboLabels[index-1].add_theme_color_override("font_color", Color.GREEN)
				comboLabels[index-1].text = "GREAT "+str(comboAmount)+"x"
			4:
				comboLabels[index-1].add_theme_color_override("font_color", Color.GOLD)
				comboLabels[index-1].text = "PERFECT "+str(comboAmount)+"x"
	if type>0:
		prevCombo+=1
	await get_tree().create_timer(1.0).timeout
	comboLabels[index-1].visible=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	healthChanges()
