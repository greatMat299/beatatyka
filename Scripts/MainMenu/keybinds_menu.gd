extends Control

const settingPath = "res://settings.ini"

@onready var settingsMenu = $"../SettingsMenu"
@onready var selectBorder = $selectBorder

var waitingForInput = false
var currentKey;
var currentLabel;
var currentSelPlayer=0

@onready var leftButtonCurrent = null
@onready var jumpButtonCurrent = null
@onready var rightButtonCurrent = null
@onready var attackButtonCurrent = null
@onready var blockButtonCurrent = null
@onready var returnButton = $MarginContainer/Container/VBoxContainer/HBoxContainer/Return
@onready var saveButton = $MarginContainer/Container/VBoxContainer/HBoxContainer/Save

static var currentAction = ""

var keyLeft = [0,0,0,0]
var keyBlock = [0,0,0,0]
var keyRight = [0,0,0,0]
var keyJump = [0,0,0,0]
var basicAttack = [0,0,0,0]
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
	for i in range(1,5):
		loadPlayerKeybinds(i,true,false)
	for i in range(1,5):
		playerButtons.append(get_node("MarginContainer/Container/HBoxContainer/Player"+str(i)+"Btn"))
	loadPlayerKeybinds(1, false, true)
	
	menuButtons.append(leftButtonCurrent.get_parent())
	menuButtons.append(rightButtonCurrent.get_parent())
	menuButtons.append(jumpButtonCurrent.get_parent())
	menuButtons.append(attackButtonCurrent.get_parent())
	menuButtons.append(blockButtonCurrent.get_parent())
	menuButtons.append(returnButton)
	menuButtons.append(saveButton)

func loadPlayerKeybinds(player:int,isInital:bool,isShow:bool):
	if isInital==true:
		keyLeft[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Left")+str(player))
		keyRight[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Right")+str(player))
		keyJump[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Jump")+str(player))
		basicAttack[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Basic_Attack")+str(player))
		keyBlock[player-1] = ConfigFileHandler.config.get_value("Keybinds", str("Block")+str(player))
	if isShow==true:
		currentPlayer=player-1
		leftButtonCurrent.text = OS.get_keycode_string(keyLeft[player-1])
		blockButtonCurrent.text = OS.get_keycode_string(keyBlock[player-1])
		rightButtonCurrent.text = OS.get_keycode_string(keyRight[player-1])
		jumpButtonCurrent.text = OS.get_keycode_string(keyJump[player-1])
		attackButtonCurrent.text = OS.get_keycode_string(basicAttack[player-1])

	
func _process(_delta):
	if visible==true and isActive==false:
		isActive=true
		await get_tree().process_frame
		changeBorderPosition(currentSelectIndex)
	elif visible==false:
		isActive=false
		
	if isActive:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_down"):
			if currentSelectIndex>-1 and currentSelectIndex<5:
				currentSelectIndex+=1
				changeBorderPosition(currentSelectIndex)
				
		if Input.is_action_just_pressed("ui_up"):
			if currentSelectIndex==6:
				currentSelectIndex-=2
				changeBorderPosition(currentSelectIndex)
			elif currentSelectIndex>0 and currentSelectIndex<6:
				currentSelectIndex-=1
				changeBorderPosition(currentSelectIndex)
				
		if Input.is_action_just_pressed("ui_right"):
			if currentSelectIndex==5:
				currentSelectIndex+=1
				changeBorderPosition(currentSelectIndex)
				
		if Input.is_action_just_pressed("ui_left"):
			if currentSelectIndex==6:
				currentSelectIndex-=1
				changeBorderPosition(currentSelectIndex)
				
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
					_on_return_pressed()
				6:
					_on_save_pressed()
					

func changeBorderPosition(index):
	selectBorder.set_deferred("global_position", menuButtons[index].global_position)
	selectBorder.set_deferred("size", menuButtons[index].size)
	selectBorder.visible=true


func _on_return_pressed() -> void:
	self.visible=false
	currentSelectIndex=0
	settingsMenu.visible=true
	isActive=false

func _on_save_pressed() -> void:
	for i in range(1,5):
		var eventAttack := InputEventKey.new()
		var eventRight := InputEventKey.new()
		var eventLeft := InputEventKey.new()
		var eventJump := InputEventKey.new()
		var eventBlock := InputEventKey.new()
		
		eventAttack.physical_keycode = basicAttack[i-1]
		eventRight.physical_keycode = keyRight[i-1]
		eventLeft.physical_keycode = keyLeft[i-1]
		eventJump.physical_keycode = keyJump[i-1]
		eventBlock.physical_keycode = keyBlock[i-1]
		
		InputMap.action_erase_events(str("player")+str(i)+str("_attack"))
		InputMap.action_erase_events(str("player")+str(i)+str("_right"))
		InputMap.action_erase_events(str("player")+str(i)+str("_left"))
		InputMap.action_erase_events(str("player")+str(i)+str("_jump"))
		InputMap.action_erase_events(str("player")+str(i)+str("_block"))
		
		InputMap.action_add_event(str("player")+str(i)+str("_attack"),eventAttack)
		InputMap.action_add_event(str("player")+str(i)+str("_right"),eventRight)
		InputMap.action_add_event(str("player")+str(i)+str("_left"),eventLeft)
		InputMap.action_add_event(str("player")+str(i)+str("_jump"),eventJump)
		InputMap.action_add_event(str("player")+str(i)+str("_block"),eventBlock)
		
		ConfigFileHandler.config.set_value("Keybinds",str("Left")+str(i),keyLeft[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Block")+str(i),keyBlock[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Right")+str(i),keyRight[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Jump")+str(i),keyJump[i-1])
		ConfigFileHandler.config.set_value("Keybinds",str("Basic_Attack")+str(i),basicAttack[i-1])
		ConfigFileHandler.config.save(settingPath)
	self.visible=false
	isActive=false
	settingsMenu.visible=true


func _on_left_button_pressed() -> void:
	currentAction="left"
	currentLabel = leftButtonCurrent
	changeBorderPosition(0)
	await get_tree().process_frame
	waitingForInput = true

func _on_block_button_pressed() -> void:
	currentAction="block"
	currentLabel = blockButtonCurrent
	changeBorderPosition(4)
	await get_tree().process_frame
	waitingForInput = true

func _on_right_button_pressed() -> void:
	currentAction="right"
	currentLabel = rightButtonCurrent
	changeBorderPosition(1)
	await get_tree().process_frame
	waitingForInput = true

func _on_jump_button_pressed() -> void:
	currentAction="jump"
	currentLabel = jumpButtonCurrent
	changeBorderPosition(2)
	await get_tree().process_frame
	waitingForInput = true


func _on_attack_button_pressed() -> void:
	currentAction="attack"
	currentLabel = attackButtonCurrent
	changeBorderPosition(3)
	await get_tree().process_frame
	waitingForInput = true


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Key.KEY_E and !waitingForInput:
			if currentSelPlayer<4:
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
			"left":
				keyLeft[currentPlayer] = currentKey
			"block":
				keyBlock[currentPlayer] = currentKey
			"right":
				keyRight[currentPlayer] = currentKey
			"jump":
				keyJump[currentPlayer] = currentKey
			"attack":
				basicAttack[currentPlayer] = currentKey
				print(currentKey)

		waitingForInput = false
		


func _on_player_btn_pressed(extra_arg_0):
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
