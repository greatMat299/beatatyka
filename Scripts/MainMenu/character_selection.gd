extends Control
@onready var buttons = $Control/HBoxContainer.get_children()
@onready var p1_frame = $Control/border_p1
@onready var p2_frame = $Control/border_p2
@onready var p3_frame = $Control/border_p3
@onready var p4_frame = $Control/border_p4
@onready var characterContainer = $Control/HBoxContainer
@onready var warnLabel = $Control/warn_label
@onready var mapSelectMenu = $"../MapSelectMenu"
@onready var menuContainer = $"../MenuContainer"
@onready var menuSelectSfx = $"../MenuSelectSfx"
@onready var menuBackSfx = $"../MenuBackSfx"
@onready var menuSwipeSfx = $"../MenuSwipeSfx"
@onready var animPlayer = $"../AnimationPlayer"
@onready var randomSelectSfx = $randomSelectSfx
@onready var mainMenuMusic = $"../MainMenuMusic"
const PLAYER_EXTRAS=["2.5X DASH na 5s", "2X DAMAGE na 5s", "+2HP co 5s", "ATAK RADIOAKTYWNY"]
var previewSprites = []
var playerLabels = []
var speedCharLabels = []
var jumpCharLabels = []
var attackCharLabels = []
var extraCharLabels=[]
var playerAmount=1
var arePlayersActive=[true,false,false,false]
var arePlayersReady=[false,false,false,false]
var isGameReady=false
var isGameLaunching=false
var enabled=false
var scene = "res://Scenes/map1.tscn"
var rng
var fade_music_tween

var index_p1 = 0;
var index_p2 = 0;
var index_p3 = 0;
var index_p4 = 0;

var characterSprites = [
	preload("res://Assets/SpriteSheets/classicGuitarFrames.tres"),
	preload("res://Assets/SpriteSheets/electricGuitarFrames.tres"),
	preload("res://Assets/SpriteSheets/saxophoneFrames.tres"),
	preload("res://Assets/SpriteSheets/djPadFrames.tres"),
	preload("res://Assets/SpriteSheets/randomCharFrames.tres")
]

var characterIcons = [
	preload("res://Assets/CharacterIcons/classicalGuitar.png"),
	preload("res://Assets/CharacterIcons/electricGuitar.png"),
	preload("res://Assets/CharacterIcons/saxophone.png"),
	preload("res://Assets/CharacterIcons/djPad.png"),
	preload("res://Assets/CharacterIcons/question_mark.png")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng = RandomNumberGenerator.new()
	
func fadeInOutMusic(isFading:bool):
	if isFading:
		if fade_music_tween:
			fade_music_tween.kill()
			fade_music_tween=null
		
		fade_music_tween = create_tween()
		fade_music_tween.tween_property(mainMenuMusic, "volume_db", -20, 0.5)
	else:
		if fade_music_tween:
			fade_music_tween.kill()
			fade_music_tween=null
		
		fade_music_tween = create_tween()
		fade_music_tween.tween_property(mainMenuMusic, "volume_db", 0, 0.5)
	
func fillUpArrays():
	for i in range(0,4):
		previewSprites.append(get_node("PreviewSprites").get_node("SpriteControl"+str(i+1)).get_node("PreviewSprite"))
		previewSprites[i].play("idle")
		
		playerLabels.append(get_node("Control").get_node("PlayerLabels").get_node("P"+str(i+1)+"Label"))
		if i>0:
			playerLabels[i].text = str("GRACZ ")+str(i+1)+str(" - NACIŚNIJ ")+OS.get_keycode_string(InputMap.action_get_events("player"+str(i+1)+"_attack")[0].physical_keycode)
		else:
			playerLabels[0].text = "GRACZ 1 - "+str(OS.get_keycode_string(InputMap.action_get_events("player1_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		
		speedCharLabels.append(get_node("PreviewSprites").get_node("SpriteControl"+str(i+1)).get_node("SpeedLabel"))
		jumpCharLabels.append(get_node("PreviewSprites").get_node("SpriteControl"+str(i+1)).get_node("JumpLabel"))
		attackCharLabels.append(get_node("PreviewSprites").get_node("SpriteControl"+str(i+1)).get_node("AttackLabel"))
		extraCharLabels.append(get_node("PreviewSprites").get_node("SpriteControl"+str(i+1)).get_node("ExtraLabel"))
		
	for i in range(0,len(characterIcons)-1):	
		get_node("Control/HBoxContainer/Postac"+str(i+1)).icon = characterIcons[i]
		
func checkIfAllReady() -> bool:
	var readyChecks=0
	if playerAmount==1:
		return false
	else:
		for i in range(0,4):
			print(i)
			if arePlayersReady[i]==true:
				readyChecks+=1
				
		if readyChecks==playerAmount:
			return true
		else:
			return false
			
func exitMenu():
	GameManager.currentPlayerKeybinds=[]
	GameManager.currentCharacterUltAttackCooldown=[]
	GameManager.playerSpriteSheets=[]
	GameManager.playerSpriteIcons=[]
	menuBackSfx.play()
	animPlayer.play("menuBack")
	await get_tree().create_timer(0.1).timeout
	enabled=false
	visible=false
	playerAmount=1
	arePlayersActive=[true,false,false,false]
	arePlayersReady=[false,false,false,false]
	menuContainer.visible=true
	menuContainer.get_parent().isActive=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enabled:
		if len(previewSprites)==0:
			fillUpArrays()
			update_sprite_preview(1,0)
			
		handle_input_p1()
		handle_input_p2()
		handle_input_p3()
		handle_input_p4()
		
		if Input.is_action_just_pressed("ui_cancel"):
			exitMenu()
		
		
		if isGameReady==true and isGameLaunching==false:
			isGameLaunching=true
			var thePlayerIndex
			for i in range(0,4):
				if arePlayersReady[i]==true:
					GameManager.currentPlayerKeybinds.append(i+1)
					match i:
						0:
							thePlayerIndex=index_p1
						1:
							thePlayerIndex=index_p2
						2:
							thePlayerIndex=index_p3
						3:
							thePlayerIndex=index_p4
					
					preparePlayer(thePlayerIndex)
						
			await get_tree().create_timer(.7).timeout
			if isGameReady==true:
				GameManager.playerLoadCount=playerAmount
				animPlayer.play("menuChange")
				menuSelectSfx.play()
				await get_tree().create_timer(.1).timeout
				self.visible=false
				enabled=false
				mapSelectMenu.visible = true
				mapSelectMenu.enabled = true
				print("lets go")
			
		if playerAmount>=2 and warnLabel.visible==true:
			warnLabel.visible=false
			
func preparePlayer(index):
	GameManager.playerSpriteSheets.append(characterSprites[index])
	GameManager.playerSpriteIcons.append(characterIcons[index])
	GameManager.setCharacterAttribute(index,0)
	GameManager.setCharacterAttribute(index,1)
	GameManager.setCharacterAttribute(index,2)
	GameManager.setCharacterAttribute(index,3)
	GameManager.setCharacterAttribute(index,4)
	
func update_frame(frame, index):
	menuSwipeSfx.play()
	var btn = buttons[index]
	frame.global_position = btn.global_position
	frame.size = btn.size

func handle_input_p1():
	if arePlayersReady[0]==false:
		playerLabels[0].text = "GRACZ 1 - "+str(OS.get_keycode_string(InputMap.action_get_events("player1_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		p1_frame.visible=true
		if Input.is_action_just_pressed("player1_right"):
			index_p1 = (index_p1 + 1) % buttons.size()
			update_frame(p1_frame, index_p1)
			update_sprite_preview(1,index_p1)
		
		if Input.is_action_just_pressed("player1_left") and index_p1>0:
			index_p1 = (index_p1 - 1)% buttons.size()
			update_frame(p1_frame,index_p1) 
			update_sprite_preview(1,index_p1)
			
		if Input.is_action_just_pressed("player1_attack"):
			print("Gracz 1 wybrał: ", index_p1)
			playerLabels[0].text = "GRACZ 1 GOTOWY"
			playerLabels[0].add_theme_color_override("font_color", Color(0.996, 0.0, 0.176, 1.0))
			p1_frame.visible=false
			arePlayersReady[0]=true
			if index_p1==len(characterSprites)-1:
				index_p1 = rng.randi_range(0,len(characterSprites)-2)
				previewSprites[0].play("random")
				fadeInOutMusic(true)
				randomSelectSfx.play()
				await get_tree().create_timer(.7).timeout
				fadeInOutMusic(false)
				update_sprite_preview(1,index_p1)
			isGameReady = checkIfAllReady()
	else:
		if Input.is_action_just_pressed("player1_attack"):
			playerLabels[0].text = "GRACZ 1 - "+str(OS.get_keycode_string(InputMap.action_get_events("player1_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
			p1_frame.visible=true
			arePlayersReady[0]=false
			playerLabels[0].add_theme_color_override("font_color",Color.WHITE)
			isGameReady = checkIfAllReady()
			isGameLaunching=false
			
func handle_input_p2():
	if arePlayersActive[1]!=false and arePlayersReady[1]==false:
		playerLabels[1].text = "GRACZ 2 - "+str(OS.get_keycode_string(InputMap.action_get_events("player2_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		p2_frame.visible=true
		if Input.is_action_just_pressed("player2_right"):
			index_p2 = (index_p2 + 1) % buttons.size()
			update_frame(p2_frame, index_p2)
			update_sprite_preview(2,index_p2)
		
		if Input.is_action_just_pressed("player2_left") and index_p2>0:
			index_p2 = (index_p2 - 1 + buttons.size()) % buttons.size()
			update_frame(p2_frame,index_p2)
			update_sprite_preview(2,index_p2)
			
	if Input.is_action_just_pressed("player2_attack"):
		if arePlayersActive[1]==false:
			speedCharLabels[1].visible = true
			jumpCharLabels[1].visible = true
			attackCharLabels[1].visible = true
			extraCharLabels[1].visible = true
			
			playerLabels[1].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
			playerAmount+=1
			arePlayersActive[1]=true
			p2_frame.visible=true
			previewSprites[1].visible=true
			playerLabels[1].text = "GRACZ 2 - "+str(OS.get_keycode_string(InputMap.action_get_events("player2_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		elif arePlayersReady[1]==true:
			if Input.is_action_just_pressed("player2_attack"):
				playerLabels[1].text = "GRACZ 2 - "+str(OS.get_keycode_string(InputMap.action_get_events("player2_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
				p2_frame.visible=true
				arePlayersReady[1]=false
				playerLabels[1].add_theme_color_override("font_color",Color.WHITE)
				isGameReady = checkIfAllReady()
				isGameLaunching=false
		else:
			print("Gracz 2 wybrał: ", index_p2)
			p2_frame.visible=false
			playerLabels[1].text = "GRACZ 2 GOTOWY"
			playerLabels[1].add_theme_color_override("font_color", Color(0.0, 0.557, 0.929, 1.0))
			arePlayersReady[1]=true
			if index_p2==len(characterSprites)-1:
				index_p2 = rng.randi_range(0,len(characterSprites)-2)
				previewSprites[1].play("random")
				fadeInOutMusic(true)
				randomSelectSfx.play()
				await get_tree().create_timer(.7).timeout
				fadeInOutMusic(false)
				update_sprite_preview(2,index_p2)
			isGameReady = checkIfAllReady()
		
func handle_input_p3():
	if arePlayersActive[2]!=false and arePlayersReady[2]==false:
		playerLabels[2].text = "GRACZ 3 - "+str(OS.get_keycode_string(InputMap.action_get_events("player3_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		p3_frame.visible=true
		if Input.is_action_just_pressed("player3_right"):
			index_p3 = (index_p3 + 1) % buttons.size()
			update_frame(p3_frame, index_p3)
			update_sprite_preview(3,index_p3)
		
		if Input.is_action_just_pressed("player3_left") and index_p3>0:
			index_p3 = (index_p3 - 1 + buttons.size()) % buttons.size()
			update_frame(p3_frame,index_p3) 
			update_sprite_preview(3,index_p3)
			
	if Input.is_action_just_pressed("player3_attack"):
		if arePlayersActive[2]==false:
			speedCharLabels[2].visible = true
			jumpCharLabels[2].visible = true
			attackCharLabels[2].visible = true
			extraCharLabels[2].visible = true
			
			playerLabels[2].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
			playerAmount+=1
			arePlayersActive[2]=true
			p3_frame.visible=true
			previewSprites[2].visible=true
			playerLabels[2].text = "GRACZ 3 - "+str(OS.get_keycode_string(InputMap.action_get_events("player3_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		elif arePlayersReady[2]==true:
			if Input.is_action_just_pressed("player3_attack"):
				playerLabels[2].text = "GRACZ 3 - "+str(OS.get_keycode_string(InputMap.action_get_events("player3_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
				p3_frame.visible=true
				arePlayersReady[2]=false
				playerLabels[2].add_theme_color_override("font_color",Color.WHITE)
				isGameReady = checkIfAllReady()
				isGameLaunching=false
		else:
			print("Gracz 3 wybrał: ", index_p3)
			p3_frame.visible=false
			playerLabels[2].text = "GRACZ 3 GOTOWY"
			playerLabels[2].add_theme_color_override("font_color", Color(0.267, 0.639, 0.0, 1.0))
			arePlayersReady[2]=true
			if index_p3==len(characterSprites)-1:
				index_p3 = rng.randi_range(0,len(characterSprites)-2)
				previewSprites[2].play("random")
				fadeInOutMusic(true)
				randomSelectSfx.play()
				await get_tree().create_timer(.7).timeout
				fadeInOutMusic(false)
				update_sprite_preview(3,index_p3)
			isGameReady = checkIfAllReady()
		
func handle_input_p4():
	if arePlayersActive[3]!=false and arePlayersReady[3]==false:
		p4_frame.visible=true
		playerLabels[3].text = "GRACZ 4 - "+str(OS.get_keycode_string(InputMap.action_get_events("player4_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		if Input.is_action_just_pressed("player4_right"):
			index_p4 = (index_p4 + 1) % buttons.size()
			update_frame(p4_frame, index_p4)
			update_sprite_preview(4,index_p4)
		
		if Input.is_action_just_pressed("player4_left") and index_p4>0:
			index_p4 = (index_p4 - 1 + buttons.size()) % buttons.size()
			update_frame(p4_frame,index_p4) 
			update_sprite_preview(4,index_p4)
			
	if Input.is_action_just_pressed("player4_attack"):
		if arePlayersActive[3]==false:
			speedCharLabels[3].visible = true
			jumpCharLabels[3].visible = true
			attackCharLabels[3].visible = true
			extraCharLabels[3].visible = true
			
			playerLabels[3].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
			playerAmount+=1
			arePlayersActive[3]=true
			p4_frame.visible=true
			previewSprites[3].visible=true
			playerLabels[3].text = "GRACZ 4 - "+str(OS.get_keycode_string(InputMap.action_get_events("player4_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
		elif arePlayersReady[3]==true:
			if Input.is_action_just_pressed("player4_attack"):
				playerLabels[3].text = "GRACZ 4 - "+str(OS.get_keycode_string(InputMap.action_get_events("player4_attack")[0].physical_keycode))+" ŻEBY POTWIERDZIĆ"
				p4_frame.visible=true
				arePlayersReady[3]=false
				playerLabels[3].add_theme_color_override("font_color",Color.WHITE)
				isGameReady = checkIfAllReady()
				isGameLaunching=false
		else:
			print("Gracz 4 wybrał: ", index_p4)
			p4_frame.visible=false
			playerLabels[3].text = "PLAYER 4 GOTOWY"
			playerLabels[3].add_theme_color_override("font_color", Color(0.62, 0.584, 0.075, 1.0))
			arePlayersReady[3]=true
			if index_p4==len(characterSprites)-1:
				index_p4 = rng.randi_range(0,len(characterSprites)-2)
				previewSprites[3].play("random")
				fadeInOutMusic(true)
				randomSelectSfx.play()
				await get_tree().create_timer(.7).timeout
				fadeInOutMusic(false)
				update_sprite_preview(4,index_p4)
			isGameReady = checkIfAllReady()
			
func update_sprite_preview(player,index):
	print("sex")
	if index<len(GameManager.CHARACTER_SPEEDS):
		previewSprites[player-1].sprite_frames = characterSprites[index]
		previewSprites[player-1].play("idle")
		speedCharLabels[player-1].text = "Szybkość: "+str(GameManager.CHARACTER_SPEEDS[index])
		jumpCharLabels[player-1].text = "Skok: "+str(abs(GameManager.CHARACTER_JUMP_VELS[index]))
		attackCharLabels[player-1].text = "Atak: "+str(GameManager.CHARACTER_ATTACK_PWRS[index])
		extraCharLabels[player-1].text = PLAYER_EXTRAS[index]
	elif index==len(GameManager.CHARACTER_SPEEDS):
		previewSprites[player-1].sprite_frames = characterSprites[index]
		previewSprites[player-1].play("idle")
		speedCharLabels[player-1].text = ""
		jumpCharLabels[player-1].text = ""
		attackCharLabels[player-1].text = ""
		extraCharLabels[player-1].text = ""

func update_preview(index):
	var btn = buttons[index]
	#if btn.icon != null:
		#preview.texture = btn.icon
	#else:
		#pass


func _on_back_btn_pressed():
	exitMenu()
