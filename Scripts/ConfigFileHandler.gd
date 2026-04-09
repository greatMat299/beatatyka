extends Node

var config
const settings_file_path = "res://settings.ini"

func _ready() -> void:
	config =ConfigFile.new()
	if(!FileAccess.file_exists(settings_file_path)):
		config.set_value("Audio", "Master_Volume", 100)
		config.set_value("Audio", "Music_Volume", 100)
		config.set_value("Audio", "Sfx_Volume", 100)
		
		config.set_value("Video","Display",0)
		config.set_value("Video", "FPSCap", 60)
		config.set_value("Video", "VSync", true)
		
		config.set_value("Keybinds", "Left1", KEY_A)
		config.set_value("Keybinds", "Right1", KEY_D)
		config.set_value("Keybinds", "Jump1", KEY_W)
		config.set_value("Keybinds", "Basic_Attack1", KEY_E)
		config.set_value("Keybinds", "Block1", KEY_Q)
		config.set_value("Keybinds", "Down1", KEY_S)
		
		config.set_value("Keybinds", "Left2", KEY_G)
		config.set_value("Keybinds", "Right2", KEY_J)
		config.set_value("Keybinds", "Jump2", KEY_Y)
		config.set_value("Keybinds", "Basic_Attack2", KEY_U)
		config.set_value("Keybinds", "Block2", KEY_T)
		config.set_value("Keybinds", "Down2", KEY_H)
		
		config.set_value("Keybinds", "Left3", KEY_L)
		config.set_value("Keybinds", "Right3", KEY_QUOTELEFT)
		config.set_value("Keybinds", "Jump3", KEY_P)
		config.set_value("Keybinds", "Basic_Attack3", KEY_BRACKETLEFT)
		config.set_value("Keybinds", "Block3", KEY_O)
		config.set_value("Keybinds", "Down3", KEY_SEMICOLON)
		
		config.set_value("Keybinds", "Left4", KEY_LEFT)
		config.set_value("Keybinds", "Right4", KEY_RIGHT)
		config.set_value("Keybinds", "Jump4", KEY_UP)
		config.set_value("Keybinds", "Basic_Attack4", KEY_CTRL)
		config.set_value("Keybinds", "Block4", KEY_SHIFT)
		config.set_value("Keybinds", "Down4", KEY_DOWN)
		
		config.save(settings_file_path)
	else:
		config.load(settings_file_path)
