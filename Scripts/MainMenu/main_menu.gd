extends Control

@onready var settingsMenu = $SettingsMenu
@onready var menuContainer = $MenuContainer
@onready var characterSelection = $CharacterSelection
@onready var selectBorder = $MenuContainer/selectBorder
@onready var menuSelectSfx = $MenuSelectSfx
@onready var menuBackSfx = $MenuBackSfx
@onready var menuPickSfx = $MenuPickSfx

var status
var scene = "res://Scenes/map1.tscn"
var scene_loaded=false
var scene_ready := false
var isActive=true
var menuButtons=[]
var currentSelectIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_volume_db(0,0)
	call_deferred("_apply_display_mode")
	call_deferred("_apply_keybinds")
	await get_tree().process_frame
	
	menuButtons.append(get_node("MenuContainer/VBoxContainer/StartButton"))
	menuButtons.append(get_node("MenuContainer/VBoxContainer/SettingsButton"))
	menuButtons.append(get_node("MenuContainer/VBoxContainer/QuitButton"))
	
	await get_tree().process_frame
	changeBorderPosition(0)
	
func _apply_keybinds():
	var keyLeft
	var keyRight
	var keyJump
	var basicAttack
	var keyBlock
	
	for i in range(1,5):
		var eventAttack := InputEventKey.new()
		var eventRight := InputEventKey.new()
		var eventLeft := InputEventKey.new()
		var eventJump := InputEventKey.new()
		var eventBlock := InputEventKey.new()
		
		keyLeft = ConfigFileHandler.config.get_value("Keybinds", str("Left")+str(i))
		keyRight = ConfigFileHandler.config.get_value("Keybinds", str("Right")+str(i))
		keyJump = ConfigFileHandler.config.get_value("Keybinds", str("Jump")+str(i))
		basicAttack = ConfigFileHandler.config.get_value("Keybinds", str("Basic_Attack")+str(i))
		keyBlock = ConfigFileHandler.config.get_value("Keybinds", str("Block")+str(i))
		
		eventAttack.physical_keycode = basicAttack
		eventRight.physical_keycode = keyRight
		eventLeft.physical_keycode = keyLeft
		eventJump.physical_keycode = keyJump
		eventBlock.physical_keycode = keyBlock
		
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
		
		
	print("sus")
	
func _apply_display_mode():
	var currentDisplay = ConfigFileHandler.config.get_value("Video", "Display")
	match currentDisplay:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if isActive==true:
		if Input.is_action_just_pressed("ui_down"):
			if currentSelectIndex>-1 and currentSelectIndex<2:
				currentSelectIndex+=1
				changeBorderPosition(currentSelectIndex)
				
		if Input.is_action_just_pressed("ui_up"):
			if currentSelectIndex>0 and currentSelectIndex<3:
				currentSelectIndex-=1
				changeBorderPosition(currentSelectIndex)
			
		if Input.is_action_just_pressed("ui_accept"):
			print("oops")
			isActive=false
			match currentSelectIndex:
				0:
					_on_start_button_pressed()
				1:
					_on_settings_button_pressed()
				2:
					_on_quit_button_pressed()
			
			

func changeBorderPosition(index):
	if len(menuButtons)>0:
		menuPickSfx.play()
		selectBorder.visible=true
		selectBorder.set_deferred("global_position", menuButtons[index].global_position)
		selectBorder.set_deferred("size", menuButtons[index].size)


func _on_start_button_pressed() -> void:
	menuSelectSfx.play()
	isActive=false
	menuContainer.visible=false
	characterSelection.enabled=true
	characterSelection.visible=true
	


func _on_settings_button_pressed() -> void:
	menuSelectSfx.play()
	get_node("SettingsMenu").visible=true
	get_node("SettingsMenu").isActive=true
	menuContainer.visible=false
	isActive=false
	


func _on_quit_button_pressed() -> void:
	menuSelectSfx.play()
	get_tree().quit(0)


func _on_menu_button_mouse_entered(extra_arg_0):
	if isActive:
		if selectBorder.visible==false:
			selectBorder.visible=true
		if extra_arg_0>=0 and extra_arg_0<=2:
			currentSelectIndex=extra_arg_0
			changeBorderPosition(extra_arg_0)


func _on_menu_button_mouse_exited():
	if isActive:
		if selectBorder.visible==true:
			selectBorder.visible=false
