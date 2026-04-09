extends HBoxContainer

var playerCount=0
var players=[]
var activeHealthLabels=[]
var comboLabels=[]
var prevCombo = 0
var crowdCheerSFX
var crowdChantSFX

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
		activeHealthLabels.push_back(self.get_node(str("Player")+str(i+1)+str("/vBox/hBox/cBox/LabelHealth")))
		comboLabels.push_back(self.get_node(str("Player")+str(i+1)+str("/vBox/LabelCombo")))
		self.get_node(str("Player")+str(i+1)+str("/vBox/hBox/cBox/LabelHealth")).visible = true
		self.get_node(str("Player")+str(i+1)+str("/vBox/LabelCombo")).visible = true
		self.get_node(str("Player")+str(i+1)+str("/vBox/hBox/vBox/hBox/cBox/gravityBuff")).modulate = Color(0.5, 0.5, 0.5, 1)
		self.get_node(str("Player")+str(i+1)+str("/vBox/hBox/vBox/hBox/cBox2/defenseBuff")).modulate = Color(0.5, 0.5, 0.5, 1)
		self.get_node(str("Player")+str(i+1)).show()
		print(GameManager.playerSpriteSheets[0])
		var icon = self.get_node(str("Player") + str(i+1)).get_node("vBox/hBox/vBox/cBox/PlayerIcon")
		icon.texture = GameManager.playerSpriteIcons[i]
		icon.custom_minimum_size = Vector2(80, 80)
		
		
		
	crowdCheerSFX = get_parent().get_parent().get_parent().get_node("CrowdCheerSFX")
	

func buffChanges():
	if get_tree().get_nodes_in_group("player")[0].isInvincible:
		$Player1/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1, 1, 1, 1)
	else:
		$Player1/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1.0, 1.0, 1.0, 0.49)
	if playerCount>=2:
		if get_tree().get_nodes_in_group("player")[1].isInvincible:
			$Player2/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1, 1, 1, 1)
		else:
			$Player2/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1.0, 1.0, 1.0, 0.49)
	if playerCount>=3:
		if get_tree().get_nodes_in_group("player")[2].isInvincible:
			$Player3/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1, 1, 1, 1)
		else:
			$Player3/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1.0, 1.0, 1.0, 0.49)
	if playerCount>=4:
		if get_tree().get_nodes_in_group("player")[3].isInvincible:
			$Player4/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1, 1, 1, 1)
		else:
			$Player4/vBox/hBox/vBox/hBox/cBox2/defenseBuff.modulate = Color(1.0, 1.0, 1.0, 0.49)

func lifeChanges():
	var p1Lifes = get_tree().get_nodes_in_group("player")[0].get_node("HealthManager").lifes
	var p2Lifes=-1
	var p3Lifes=-1
	var p4Lifes=-1
	
	if get_tree().get_nodes_in_group("player")[0].get_node("HealthManager").lifes>0:
		for i in range(0,3):
			if (i+1)>p1Lifes:
				$Player1/hBox.get_child(i).visible=false
			else:
				$Player1/hBox.get_child(i).visible=true
				
	if GameManager.player_count>=2:
		p2Lifes = get_tree().get_nodes_in_group("player")[1].get_node("HealthManager").lifes
		if get_tree().get_nodes_in_group("player")[1].get_node("HealthManager").lifes>0:
			for i in range(0,3):
				if (i+1)>p2Lifes:
					$Player2/hBox.get_child(i).visible=false
				else:
					$Player2/hBox.get_child(i).visible=true
				
	if GameManager.player_count>=3:
		p3Lifes = get_tree().get_nodes_in_group("player")[2].get_node("HealthManager").lifes
		if get_tree().get_nodes_in_group("player")[2].get_node("HealthManager").lifes>0:
			for i in range(0,3):
				if (i+1)>p3Lifes:
					$Player3/hBox.get_child(i).visible=false
				else:
					$Player3/hBox.get_child(i).visible=true
				
	if GameManager.player_count>=4:
		p4Lifes = get_tree().get_nodes_in_group("player")[3].get_node("HealthManager").lifes
		if get_tree().get_nodes_in_group("player")[3].get_node("HealthManager").lifes>0:
			for i in range(0,3):
				if (i+1)>p4Lifes:
					$Player4/hBox.get_child(i).visible=false
				else:
					$Player4/hBox.get_child(i).visible=true

func healthChanges():
	if len(activeHealthLabels)>0:
		if GameManager.arePlayersAlive[0]==false:
			activeHealthLabels[0].add_theme_color_override("font_color", Color.RED)
			activeHealthLabels[0].text=str("DEAD!")
		else:
			activeHealthLabels[0].text=str(int(players[0].get_node("HealthManager").health))
		if playerCount>=2:
			if GameManager.arePlayersAlive[1]==false:
				activeHealthLabels[1].add_theme_color_override("font_color", Color.RED)
				activeHealthLabels[1].text=str("DEAD!")
			else:
				activeHealthLabels[1].text=str(int(players[1].get_node("HealthManager").health))
		if playerCount>=3:
			if GameManager.arePlayersAlive[2]==false:
				activeHealthLabels[2].add_theme_color_override("font_color", Color.RED)
				activeHealthLabels[2].text=str("DEAD!")
			else:
				activeHealthLabels[2].text=str(int(players[2].get_node("HealthManager").health))
		if playerCount>=4:
			if GameManager.arePlayersAlive[3]==false:
				activeHealthLabels[3].add_theme_color_override("font_color", Color.RED)
				activeHealthLabels[3].text=str("DEAD!")
			else:
				activeHealthLabels[3].text=str(int(players[3].get_node("HealthManager").health))



func _on_beat_attacked(index,type,comboAmount):
	comboLabels[index-1].visible=true
	if comboAmount==3:
		crowdCheerSFX.play()
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
	if GameManager.isGamePlaying==true:
		healthChanges()
		buffChanges()
		lifeChanges()
	
