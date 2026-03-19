extends Control

const settingPath = "res://settings.ini"
@onready var keybindsMenu = $"../KeybindsMenu"
@onready var menuContainer = $"../MenuContainer"
@onready var selectBorder = $selectBorder
@onready var menuSelectSfx = $"../MenuSelectSfx"
@onready var menuBackSfx = $"../MenuBackSfx"
@onready var menuPickSfx = $"../MenuPickSfx"

var masterVolume
var currentDisplay
var displayModes
var fpsCap
var vsync

var isActive=false
var currentSelectIndex=0
var settingsButtons=[]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fpsCap = ConfigFileHandler.config.get_value("Video","FPSCap")
	masterVolume = ConfigFileHandler.config.get_value("Audio", "Master_Volume")
	currentDisplay = ConfigFileHandler.config.get_value("Video", "Display")
	displayModes = ["WINDOW", "BORDERLESS WINDOW", "FULLSCREEN"]
	vsync = ConfigFileHandler.config.get_value("Video","VSync")
	loadValues()
	
	settingsButtons.append(get_node("MarginContainer/VBoxContainer/GridContainer/DisplayMode"))
	settingsButtons.append(get_node("MarginContainer/VBoxContainer/GridContainer/VSync"))
	settingsButtons.append(get_node("MarginContainer/VBoxContainer/GridContainer/FPS"))
	settingsButtons.append(get_node("MarginContainer/VBoxContainer/Keybinds"))
	settingsButtons.append(get_node("MarginContainer/Return"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if visible==true and isActive==false:
		changeBorderPosition(currentSelectIndex)
		isActive=true
	
	if isActive==true:
		if Input.is_action_just_pressed("ui_down"):
			if currentSelectIndex>-1 and currentSelectIndex<4:
				currentSelectIndex+=1
				changeBorderPosition(currentSelectIndex)
				
		if Input.is_action_just_pressed("ui_up"):
			if currentSelectIndex>0 and currentSelectIndex<5:
				currentSelectIndex-=1
				changeBorderPosition(currentSelectIndex)
				
		if Input.is_action_just_pressed("ui_accept"):
			print("oops")
			isActive=false
			match currentSelectIndex:
				0:
					_on_display_mode_pressed()
				1:
					_on_v_sync_pressed()
				2:
					_on_fps_pressed()
				3:
					_on_keybinds_pressed()
				4:
					_on_return_pressed()
					
		if Input.is_action_just_pressed("ui_cancel"):
			_on_return_pressed()

func changeBorderPosition(index):
	menuPickSfx.play()
	selectBorder.visible=true
	selectBorder.set_deferred("global_position", settingsButtons[index].global_position)
	selectBorder.set_deferred("size", settingsButtons[index].size)


func _on_volume_value_changed(value: float) -> void:
	masterVolume = int(value)
	ConfigFileHandler.config.set_value("Audio","Master_Volume",masterVolume)
	ConfigFileHandler.config.save(settingPath)
	
	var db = linear_to_db(masterVolume / 100.0)
	AudioServer.set_bus_volume_db(0, db)
	
	get_node("MarginContainer/VBoxContainer/GridContainer/HFlowContainer/VolumeValue").text = str(masterVolume)


func _on_display_mode_pressed() -> void:
	var button = get_node("MarginContainer/VBoxContainer/GridContainer/DisplayMode")
	
	currentDisplay+=1;
	if (currentDisplay > 2):
		currentDisplay = 0;
	
	ConfigFileHandler.config.set_value("Video","Display",currentDisplay)
	ConfigFileHandler.config.save(settingPath)
	
	match currentDisplay:
		0:
			button.text = displayModes[0]
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			button.text = displayModes[1]
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2:
			button.text = displayModes[2]
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)


func _on_return_pressed() -> void:
	menuBackSfx.play()
	self.visible=false
	isActive=false
	currentSelectIndex=0
	menuContainer.get_parent().isActive=true
	menuContainer.visible=true

func _on_v_sync_pressed() -> void:
	var button = get_node("MarginContainer/VBoxContainer/GridContainer/VSync")
	vsync = !vsync
	ConfigFileHandler.config.set_value("Video","VSync",vsync)
	ConfigFileHandler.config.save(settingPath)
	if (vsync):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		button.text = "ON"
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		button.text = "OFF"

		
func _on_fps_pressed() -> void:
	var button = get_node("MarginContainer/VBoxContainer/GridContainer/FPS")
	match fpsCap:
		60:
			fpsCap = 144
			button.text = "144"
		144: 
			fpsCap = 0
			button.text = "UNLIMITED"
		0:
			fpsCap = 60
			button.text = "60"
	Engine.max_fps = fpsCap
	ConfigFileHandler.config.set_value("Video","FPSCap",fpsCap)
	ConfigFileHandler.config.save(settingPath)
	


func _on_keybinds_pressed() -> void:
	menuSelectSfx.play()
	self.visible=false
	currentSelectIndex=0
	isActive=false
	keybindsMenu.visible=true

func loadValues() -> void:
	AudioServer.set_bus_volume_db(0, masterVolume)
	get_node("MarginContainer/VBoxContainer/GridContainer/HFlowContainer/Volume").value = masterVolume
	get_node("MarginContainer/VBoxContainer/GridContainer/HFlowContainer/VolumeValue").text = str(masterVolume)
	get_node("MarginContainer/VBoxContainer/GridContainer/DisplayMode").text = displayModes[currentDisplay]
	if(vsync): 
		get_node("MarginContainer/VBoxContainer/GridContainer/VSync").text = "ON"
	else:
		get_node("MarginContainer/VBoxContainer/GridContainer/VSync").text = "OFF"

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	await get_tree().process_frame

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

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)

	var button = get_node("MarginContainer/VBoxContainer/GridContainer/FPS")
	if fpsCap==0:
		button.text = "UNLIMITED"
	else:
		button.text = str(fpsCap)
	Engine.max_fps = fpsCap


func _on_button_mouse_entered(extra_arg_0):
	changeBorderPosition(extra_arg_0)


func _on_button_mouse_exited():
	selectBorder.visible=false
	currentSelectIndex=0
