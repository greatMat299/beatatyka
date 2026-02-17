extends Control

@onready var settingsMenu = $SettingsMenu
@onready var menuContainer = $MenuContainer
@onready var characterSelection = $CharacterSelection
var status
var scene = "res://Scenes/map1.tscn"
var scene_loaded=false
var scene_ready := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_volume_db(0,0)
	call_deferred("_apply_display_mode")
	call_deferred("_apply_keybinds")
	await get_tree().process_frame
	
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
func _process(delta: float) -> void:
	var progress=[]
	ResourceLoader.load_threaded_get_status(scene,progress)
	if progress[0]==1:
		var packedScene = ResourceLoader.load_threaded_get(scene)
		get_tree().change_scene_to_packed(packedScene)


func _on_start_button_pressed() -> void:
	menuContainer.visible=false
	characterSelection.enabled=true
	characterSelection.visible=true
	


func _on_settings_button_pressed() -> void:
	get_node("SettingsMenu").visible=true
	menuContainer.visible=false
	


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)
