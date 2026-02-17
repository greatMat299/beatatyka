extends Control

const settingPath = "res://settings.ini"
@onready var keybindsMenu = $"../KeybindsMenu"
@onready var menuContainer = $"../MenuContainer"

var masterVolume
var currentDisplay
var displayModes
var fpsCap
var vsync

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fpsCap = ConfigFileHandler.config.get_value("Video","FPSCap")
	masterVolume = ConfigFileHandler.config.get_value("Audio", "Master_Volume")
	currentDisplay = ConfigFileHandler.config.get_value("Video", "Display")
	displayModes = ["WINDOW", "BORDERLESS WINDOW", "FULLSCREEN"]
	vsync = ConfigFileHandler.config.get_value("Video","VSync")
	loadValues()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	self.visible=false
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
	self.visible=false
	keybindsMenu.visible=true


func _on_audio_test_pressed() -> void:
	pass # Change scene to audio test

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

	Engine.max_fps = fpsCap
