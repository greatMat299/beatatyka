extends VBoxContainer

@onready var resultLabel = $"ResultLabel"
@onready var animPlayer = $"../AnimationPlayer"
@export var playerContainerScene : PackedScene
var trophyImages = [
	preload("res://Assets/Images/OtherAssets/FirstPlace.png"),
	preload("res://Assets/Images/OtherAssets/SecondPlace.png"),
	preload("res://Assets/Images/OtherAssets/ThirdPlace.png"),
	preload("res://Assets/Images/OtherAssets/FourthPlace.png"),
]
var players=[]
var playerHealths=[]
var playerHealthsSorted=[]
var maxHealth=0
var minHealth=101
var maxHealthId=-1
var isExiting=false
var menuMapPath="res://Scenes/MainMenu/main_menu.tscn"
var progress=[]

func sort_by_health_desc(a, b):
	return a>b

func _process(delta):
	if isExiting==true:
		ResourceLoader.load_threaded_request(menuMapPath)
		var progress=[]
		ResourceLoader.load_threaded_get_status(menuMapPath,progress)
		if progress[0]==1:
			var packedScene = ResourceLoader.load_threaded_get(menuMapPath)
			get_tree().change_scene_to_packed(packedScene)
			GameManager.hasPlayedRound=true
			GameManager.resetGameManager()
			
	if GameManager.isGamePlaying==false and GameManager.hasStartSeqFinished==true and isExiting==false:
		players = get_tree().get_nodes_in_group("player")
		if maxHealth==0:
			var i=0
			for player in players:
				var playerContCopy = playerContainerScene.instantiate()
				var currentHealth = player.get_node("HealthManager").health
				playerContCopy.get_node("VBoxContainer/HealthLabel").text=str(currentHealth)
				playerContCopy.get_node("VBoxContainer/TextureRect").sprites = GameManager.playerSpriteSheets[i]
				get_node("PlayerStatus").add_child(playerContCopy)
				playerHealths.append(currentHealth)
				if currentHealth>maxHealth:
					maxHealth=currentHealth
					maxHealthId=player.player_id
				elif currentHealth<minHealth:
					minHealth=currentHealth
				i+=1
			i=0
			
			playerHealthsSorted = playerHealths.duplicate()
			playerHealthsSorted.sort_custom(sort_by_health_desc)
			
			if playerHealthsSorted[0]==playerHealthsSorted[1]:
				resultLabel.text = "REMIS!"
			else:
				resultLabel.text = "GRACZ "+str(maxHealthId)+" WYGRYWA!"
			
			if GameManager.player_count>1:
				for j in range(0,len(players)):
					var pHealth = playerHealths[j]
					var pHealthIndex = playerHealthsSorted.find(pHealth)
					get_node("PlayerStatus").get_child(j).get_node("VBoxContainer/TextureRect2").texture = trophyImages[pHealthIndex]
			else:
				print("susamongus")
				for j in range(0,len(GameManager.playersDeadOrder)):
					var maxPlayers = len(GameManager.playersDeadOrder)
					var curDeadIndex = GameManager.playersDeadOrder[j]
					get_node("PlayerStatus").get_child(curDeadIndex-1).get_node("VBoxContainer/TextureRect2").texture = trophyImages[maxPlayers-j]
				var pHealthIndex = playerHealths.find(maxHealth)
				get_node("PlayerStatus").get_child(pHealthIndex).get_node("VBoxContainer/TextureRect2").texture = trophyImages[0]


func _on_return_to_menu_btn_pressed():
	animPlayer.play("levelExit")
	await get_tree().create_timer(.1).timeout
	isExiting=true
	
