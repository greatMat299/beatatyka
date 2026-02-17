extends Control

const settingPath = "res://settings.ini"

@onready var settingsMenu = $"../SettingsMenu"

static var waitingForInput = false
static var currentKey;
static var currentLabel;

@onready var leftButtonCurrent = null
@onready var jumpButtonCurrent = null
@onready var rightButtonCurrent = null
@onready var attackButtonCurrent = null
@onready var blockButtonCurrent = null

static var currentAction = ""

var keyLeft = [0,0,0,0]
var keyBlock = [0,0,0,0]
var keyRight = [0,0,0,0]
var keyJump = [0,0,0,0]
var basicAttack = [0,0,0,0]

var currentPlayer

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
	loadPlayerKeybinds(1, false, true)

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

	

func _on_return_pressed() -> void:
	self.visible=false
	settingsMenu.visible=true

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
	settingsMenu.visible=true


func _on_left_button_pressed() -> void:
	waitingForInput = true
	currentAction="left"
	currentLabel = leftButtonCurrent

func _on_block_button_pressed() -> void:
	waitingForInput = true
	currentAction="block"
	currentLabel = blockButtonCurrent

func _on_right_button_pressed() -> void:
	waitingForInput = true
	currentAction="right"
	currentLabel = rightButtonCurrent

func _on_jump_button_pressed() -> void:
	waitingForInput = true
	currentAction="jump"
	currentLabel = jumpButtonCurrent


func _on_attack_button_pressed() -> void:
	waitingForInput = true
	currentAction="attack"
	currentLabel = attackButtonCurrent


func _input(event: InputEvent) -> void:
	if(event is InputEventKey and waitingForInput == true):
		
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
	loadPlayerKeybinds(extra_arg_0,false,true)
