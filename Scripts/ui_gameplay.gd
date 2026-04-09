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
		players.push_back(get_parent().get_parent().get_parent().get_node("Player"+str(i+1)))
		activeHealthLabels.push_back(self.get_node("Player"+str(i+1)+"/Player/cBox/LabelHealth"))
		comboLabels.push_back(self.get_node("Player"+str(i+1)+"/Player/vBox/LabelCombo"))
		self.get_node("Player"+str(i+1)+"/Player/cBox/LabelHealth").visible = true
		self.get_node("Player"+str(i+1)+"/Player/vBox/LabelCombo").visible = true
		self.get_node("Player"+str(i+1)+"/Player/vBox/hBox/vBox/hBox/cBox/gravityBuff").modulate = Color(0.5, 0.5, 0.5, 1)
		self.get_node("Player"+str(i+1)+"/Player/vBox/hBox/vBox/hBox/cBox2/defenseBuff").modulate = Color(0.5, 0.5, 0.5, 1)
		self.get_node("Player"+str(i+1)).show()
		print(GameManager.playerSpriteSheets[0])
		var icon = self.get_node("Player"+str(i+1)).get_node("Player/vBox/hBox/vBox/cBox/PlayerIcon")
		icon.texture = GameManager.playerSpriteIcons[i]
		icon.custom_minimum_size = Vector2(80, 80)
		
	crowdCheerSFX = get_parent().get_parent().get_parent().get_node("CrowdCheerSFX")
func buffChanges():
	var players = get_tree().get_nodes_in_group("player")
	for i in range(players.size()):
		var player_node = get_node("Player"+str(i+1)+"/Player/vBox/hBox/vBox/hBox/cBox2/defenseBuff")
		if players[i].isInvincible:
			player_node.modulate = Color(1, 1, 1, 1)
		else:
			player_node.modulate = Color(1, 1, 1, 0.5)

func lifeChanges():
	var players = get_tree().get_nodes_in_group("player")
	
	for i in range(players.size()):
		var player = players[i]
		var lifes = player.get_node("HealthManager").lifes
		if lifes > 0:
			var lifeIcons = get_node("Player" + str(i + 1) + "/Player/vBox2")
			for j in range(3):
				if (j + 1) <= lifes:
					lifeIcons.get_child(j).visible = true
				else:
					lifeIcons.get_child(j).visible = false


func healthChanges():
	for i in range(0, len(activeHealthLabels)):
		if GameManager.arePlayersAlive[i] == false:
			activeHealthLabels[i].add_theme_color_override("font_color", Color.RED)
			activeHealthLabels[i].text = "DEAD!"
		else:
			var health = players[i].get_node("HealthManager").health
			activeHealthLabels[i].text = str(int(health))



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
	
