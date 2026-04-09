extends Control

const settingPath = "res://settings.ini"

@onready var settingsMenu = $"../SettingsMenu"
@onready var selectBorder = $selectBorder
@onready var menuSelectSfx = $"../MenuSelectSfx"
@onready var menuBackSfx = $"../MenuBackSfx"
@onready var menuPickSfx = $"../MenuPickSfx"
@onready var animPlayer = $"../AnimationPlayer"
@onready var saveAlert = $MarginContainer/Container/VBoxContainer/HBoxContainer/SaveAlert

var waitingForInput = false
var currentKey;
var currentLabel;
var currentSelPlayer=0
@export var normalStyles:Array[StyleBox]=[]
@export var highlightedStyles:Array[StyleBox]=[]

@onready var leftButtonCurrent = null
@onready var jumpButtonCurrent = null
@onready var rightButtonCurrent = null
@onready var attackButtonCurrent = null
@onready var blockButtonCurrent = null
@onready var downButtonCurrent = null
@onready var returnButton = $MarginContainer/Container/VBoxContainer/HBoxContainer/Return
@onready var saveButton = $MarginContainer/Container/VBoxContainer/HBoxContainer/Save

static var currentAction = ""

var keyLeft = [0,0,0,0]
var keyBlock = [0,0,0,0]
var keyRight = [0,0,0,0]
var keyJump = [0,0,0,0]
var basicAttack = [0,0,0,0]
var keyDown = [0,0,0,0]
var playerColors=[
	Color(0.996, 0.0, 0.176, 1.0),
	Color(0.0, 0.557, 0.929, 1.0),
	Color(0.267, 0.639, 0.0, 1.0),
	Color(0.62, 0.584, 0.075, 1.0)
]
var playerButtons=[]

var currentPlayer
var isActive=false
var currentSelectIndex=0
var menuButtons=[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentPlayer=1
	if name=="KeybindsMenu":
		leftButtonCurrent = $MarginContainer/Container/VBoxContainer/LeftButton/HBoxContainer/CurrentLeftKey
		jumpButtonCurrent = $MarginContainer/Container/VBoxContainer/JumpButton/HBoxContainer/CurrentJumpKey
		rightButtonCurrent = $MarginContainer/Container/VBoxContainer/RightButton/HBoxContainer/CurrentRightKey
		attackButtonCurrent = $MarginContainer/Container/VBoxContainer/AttackButton/HBoxContainer/CurrentAttackKey
		blockButtonCurrent = $MarginContainer/Container/VBoxContainer/BlockButton/HBoxContainer/CurrentBlockKey	
		downButtonCurrent = $MarginContainer/Container/VBoxContainer/DownButton/HBoxContainer/CurrentDownKey
	for i in range(1,5):
		loadPlayerKeybinds(i,true,false)
	for i in range(1,5):
		playerButtons.append(get_node("MarginContainer/Container/HBoxContainer/Player"+str(i)+"Btn"))
	#loadPlayerKeybinds(1, false, true)
	currentSelPlayer=1
	_on_player_btn_pressed(currentSelPlayer)
	
	menuButtons.append(leftButtonCurrent.get_parent().get_parent())
	menuButtons.append(rightButtonCurrent.get_parent().get_parent())
	menuButtons.append(jumpButtonCurrent.get_parent().get_parent())
	menuButtons.append(attackButtonCurrent.get_parent().get_parent())
	menuButtons.append(blockButtonCurrent.get_parent().get_parent())
	menuButtons.append(downButtonCurrent.get_parent().get_parent())
	menuButtons.append(returnButton)
	menuButtons.append(saveButton)

func loadPlayerKeybinds(player:int,isInital:bool,isShow:bool):
	if isInital==true:
		keyLeft[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Left")+str(player))
		keyRight[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Right")+str(player))
		keyJump[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Jump")+str(player))
		basicAttack[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Basic_Attack")+str(player))
		keyBlock[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Block")+str(player))
		keyDown[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Down")+str(player))
	if isShow==true:
		currentPlayer=player-1
		leftButtonCurrent.text = OS.get_keycode_string(keyLeft[player-1])
		blockButtonCurrent.text = OS.get_keycode_string(keyBlock[player-1])
		rightButtonCurrent.text = OS.get_keycode_string(keyRight[player-1])
		jumpButtonCurrent.text = OS.get_keycode_string(keyJump[player-1])
		attackButtonCurrent.text = OS.get_keycode_string(basicAttack[player-1])
		downButtonCurrent.text = OS.get_keycode_string(keyDown[player-1])

	
func _process(_delta):
	if visible==true and isActive==false:
		isActive=true
		await get_tree().process_frame
	elif visible==false:
		isActive=false
		
	if isActive:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_down"):
			if currentSelectIndex>-1 and currentSelectIndex<6:
				currentSelectIndex+=1
				changeBorderPosition(currentSelectIndex,"down")
				
		if Input.is_action_just_pressed("ui_up"):
			if currentSelectIndex==7:
				currentSelectIndex-=2
				changeBorderPosition(currentSelectIndex,"up")
			elif currentSelectIndex>0 and currentSelectIndex<7:
				currentSelectIndex-=1
				changeBorderPosition(currentSelectIndex,"up")
				
		if Input.is_action_just_pressed("ui_right"):
			if currentSelectIndex==6:
				currentSelectIndex+=1
				changeBorderPosition(currentSelectIndex,"down")
				
		if Input.is_action_just_pressed("ui_left"):
			if currentSelectIndex==7:
				currentSelectIndex-=1
				changeBorderPosition(currentSelectIndex,"up")
				
		if Input.is_action_just_pressed("ui_cancel"):
			_on_return_pressed()
				
		if Input.is_action_just_pressed("ui_accept"):
			print("oops")
			isActive=false
			match currentSelectIndex:
				0:
					_on_left_button_pressed()
				1:
					_on_right_button_pressed()
				2:
					_on_jump_button_pressed()
				3:
					_on_attack_button_pressed()
				4:
					_on_block_button_pressed()
				5:
					_on_down_button_pressed()
				6:
					_on_return_pressed()
				7:
					_on_save_pressed()
					
func changePanelTextColor(index,dir):
	if index>5 and index<8:
		if dir=="up":
			menuButtons[index].add_theme_color_override("font_color", Color.BLACK)
			if index<7:
				menuButtons[index+1].add_theme_color_override("font_color", Color.WHITE)
		elif dir=="down":
			menuButtons[index].add_theme_color_override("font_color", Color.BLACK)
			if index>0:
				if index!=6:
					menuButtons[index-1].add_theme_color_override("font_color", Color.WHITE)
				else:
					menuButtons[index-1].get_node("HBoxContainer").get_child(0).add_theme_color_override("font_color", Color.WHITE)
					menuButtons[index-1].get_node("HBoxContainer").get_child(1).add_theme_color_override("font_color", Color.WHITE)
	else:
		for i in range(0,2):
			if dir=="up":
				menuButtons[index].get_node("HBoxContainer").get_child(i).add_theme_color_override("font_color", Color.BLACK)
				if index>=0 and index<5:
					menuButtons[index+1].get_node("HBoxContainer").get_child(i).add_theme_color_override("font_color", Color.WHITE)
				if index==5:
					menuButtons[index+1].add_theme_color_override("font_color", Color.WHITE)
					menuButtons[index+2].add_theme_color_override("font_color", Color.WHITE)
				if index==6:
					menuButtons[index+1].add_theme_color_override("font_color", Color.WHITE)

			elif dir=="down":
				menuButtons[index].get_node("HBoxContainer").get_child(i).add_theme_color_override("font_color", Color.BLACK)
				if index>0:
					menuButtons[index-1].get_node("HBoxContainer").get_child(i).add_theme_color_override("font_color", Color.WHITE)
			elif dir=="hover":
				for j in range(0, len(menuButtons)):
					var container = menuButtons[j].get_node_or_null("HBoxContainer")
					if container:
						for child in container.get_children():
							if child is Label or child is Button:
								if j == index:
									child.add_theme_color_override("font_color", Color.BLACK)
								else:
									child.add_theme_color_override("font_color", Color.WHITE)
					else:
						if j == index:
							menuButtons[j].add_theme_color_override("font_color", Color.BLACK)
						else:
							menuButtons[j].add_theme_color_override("font_color", Color.WHITE)
			elif dir=="remove":
				for j in range(0, len(menuButtons)):
					menuButtons[j].get_node("HBoxContainer").get_child(i).add_theme_color_override("font_color", Color.WHITE)
				
func changeBorderPosition(index,dir):
	menuPickSfx.play()
	if len(menuButtons)>0:
		if dir=="up":
			menuButtons[index].add_theme_stylebox_override("normal", highlightedStyles[index])
			changePanelTextColor(index,"up")
			menuButtons[index+1].add_theme_stylebox_override("normal", normalStyles[index+1])			
			
			#usuwamy na wszelki wypadek żeby w przypadku dolnych przycisków nie było obu podświetlonych
			if index<len(menuButtons)-2:
				menuButtons[index+2].add_theme_stylebox_override("normal", normalStyles[index+2])
		elif dir=="down":
			menuButtons[index].add_theme_stylebox_override("normal", highlightedStyles[index])
			changePanelTextColor(index,"down")
			if index>0:
				menuButtons[index-1].add_theme_stylebox_override("normal", normalStyles[index-1])
		elif dir=="hover":
			for i in range(0,len(menuButtons)):
				if i!=index:
					menuButtons[i].add_theme_stylebox_override("normal", normalStyles[index])
					changePanelTextColor(index,"hover")
				else:
					menuButtons[i].add_theme_stylebox_override("normal", highlightedStyles[index])
		elif dir=="remove":
			for i in range(0,len(menuButtons)):
				menuButtons[i].add_theme_stylebox_override("normal", normalStyles[index])
				changePanelTextColor(index,"remove")


func _on_return_pressed() -> void:
	menuBackSfx.play()
	animPlayer.play("menuBack")
	await get_tree().create_timer(0.1).timeout
	self.visible=false
	currentSelectIndex=0
	settingsMenu.visible=true
	isActive=false

func _on_save_pressed() -> void:
	if saveAlert.visible==true:
		saveAlert.visible=false
		
	for i in range(1,5):
		var eventAttack := InputEventKey.new()
		var eventRight := InputEventKey.new()
		var eventLeft := InputEventKey.new()
		var eventJump := InputEventKey.new()
		var eventBlock := InputEventKey.new()
		var eventDown := InputEventKey.new()
		
		eventAttack.physical_keycode = basicAttack[i-1]
		eventRight.physical_keycode = keyRight[i-1]
		eventLeft.physical_keycode = keyLeft[i-1]
		eventJump.physical_keycode = keyJump[i-1]
		eventBlock.physical_keycode = keyBlock[i-1]
		eventDown.physical_keycode = keyDown[i-1]
		
		InputMap.action_erase_events(str("player")+str(i)+str("_attack"))
		InputMap.action_erase_events(str("player")+str(i)+str("_right"))
		InputMap.action_erase_events(str("player")+str(i)+str("_left"))
		InputMap.action_erase_events(str("player")+str(i)+str("_jump"))
		InputMap.action_erase_events(str("player")+str(i)+str("_block"))
		InputMap.action_erase_events(str("player")+str(i)+str("_down"))
		
		InputMap.action_add_event(str("player")+str(i)+str("_attack"),eventAttack)
		InputMap.action_add_event(str("player")+str(i)+str("_right"),eventRight)
		InputMap.action_add_event(str("player")+str(i)+str("_left"),eventLeft)
		InputMap.action_add_event(str("player")+str(i)+str("_jump"),eventJump)
		InputMap.action_add_event(str("player")+str(i)+str("_block"),eventBlock)
		InputMap.action_add_event(str("player")+str(i)+str("_down"),eventDown)
		
		ConfigFileHandler.config.set_value("Keybinds",str("Left")+str(i),keyLeft[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Block")+str(i),keyBlock[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Right")+str(i),keyRight[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Jump")+str(i),keyJump[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Basic_Attack")+str(i),basicAttack[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Down")+str(i),keyDown[i-1])
		ConfigFileHandler.config.save(settingPath)


func _on_left_button_pressed() -> void:
	currentAction="Left"
	currentLabel = leftButtonCurrent
	changeBorderPosition(0,"hover")
	await get_tree().process_frame
	waitingForInput = true

func _on_block_button_pressed() -> void:
	currentAction="Block"
	currentLabel = blockButtonCurrent
	changeBorderPosition(4,"hover")
	await get_tree().process_frame
	waitingForInput = true

func _on_right_button_pressed() -> void:
	currentAction="Right"
	currentLabel = rightButtonCurrent
	changeBorderPosition(1,"hover")
	await get_tree().process_frame
	waitingForInput = true

func _on_jump_button_pressed() -> void:
	currentAction="Jump"
	currentLabel = jumpButtonCurrent
	changeBorderPosition(2,"hover")
	await get_tree().process_frame
	waitingForInput = true


func _on_attack_button_pressed() -> void:
	currentAction="Basic_Attack"
	currentLabel = attackButtonCurrent
	changeBorderPosition(3,"hover")
	await get_tree().process_frame
	waitingForInput = true
	
func _on_down_button_pressed():
	currentAction="Down"
	currentLabel = downButtonCurrent
	changeBorderPosition(5,"hover")
	await get_tree().process_frame
	waitingForInput = true


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Key.KEY_E and !waitingForInput:
			if currentSelPlayer<5:
				currentSelPlayer+=1
				_on_player_btn_pressed(currentSelPlayer)
				
		if event.keycode == Key.KEY_Q and !waitingForInput:
			if currentSelPlayer>1:
				currentSelPlayer-=1
				_on_player_btn_pressed(currentSelPlayer)
			
	if event is InputEventKey and event.pressed and not event.echo and waitingForInput:
		currentKey = event.keycode
		print(currentKey)
		currentLabel.text = OS.get_keycode_string(currentKey)
		
		match currentAction:
			"Left":
				keyLeft[currentPlayer] = currentKey
			"Block":
				keyBlock[currentPlayer] = currentKey
			"Right":
				keyRight[currentPlayer] = currentKey
			"Jump":
				keyJump[currentPlayer] = currentKey
			"Basic_Attack":
				basicAttack[currentPlayer] = currentKey
				print(currentKey)
			"Down":
				keyDown[currentPlayer] = currentKey
		
		saveAlert.visible=true
		waitingForInput = false
		


func _on_player_btn_pressed(extra_arg_0):
	currentSelPlayer=extra_arg_0
	for i in range(0,4):
		var style_box_i: StyleBoxFlat = playerButtons[i].get_theme_stylebox("normal")
		playerColors[i].a=1.0
		style_box_i.bg_color = playerColors[i]
		playerButtons[i].add_theme_stylebox_override("normal", style_box_i)
		
	var style_box: StyleBoxFlat = playerButtons[extra_arg_0-1].get_theme_stylebox("normal")
	playerColors[extra_arg_0-1].a=0.35
	style_box.bg_color = playerColors[extra_arg_0-1]
	playerButtons[extra_arg_0-1].add_theme_stylebox_override("normal", style_box)
	
	loadPlayerKeybinds(extra_arg_0,false,true)


func _on_button_mouse_entered(extra_arg_0):
	if isActive:
		if selectBorder.visible==false:
			selectBorder.visible=true
		if extra_arg_0>=0 and extra_arg_0<=6:
			currentSelectIndex=extra_arg_0
			changeBorderPosition(extra_arg_0,"hover")
