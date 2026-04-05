extends Control

@onready var pauseMenuContainer = $TextureRect/PauseMenuContainer
@onready var animPlayer = $"../AnimationPlayer"
var buttons=[]
var normalStyleBox = load("res://Assets/Styles/normalButtonStyle.tres")
var highlightStyleBox = load("res://Assets/Styles/highlightedButtonStyle.tres")
var currentSelection=0
var isExiting=false
var menuMapPath="res://Scenes/MainMenu/main_menu.tscn"
var progress=[]

func _ready():
	await get_tree().process_frame
	buttons.append(pauseMenuContainer.get_node("ContinueBtn"))
	buttons.append(pauseMenuContainer.get_node("ExitBtn"))
	changeButtonStyle()

func _process(_delta):
	if isExiting==true:
		ResourceLoader.load_threaded_request(menuMapPath)
		var progress=[]
		ResourceLoader.load_threaded_get_status(menuMapPath,progress)
		if progress[0]==1:
			var packedScene = ResourceLoader.load_threaded_get(menuMapPath)
			get_tree().change_scene_to_packed(packedScene)
			GameManager.hasPlayedRound=true
			GameManager.resetGameManager()
	
	if GameManager.isGamePlaying==false:
		self.visible=false
	else:
		if visible:
			if Input.is_action_just_pressed("ui_right"):
				if currentSelection<1 and currentSelection>-1:
					currentSelection+=1
					changeButtonStyle()
				
			if Input.is_action_just_pressed("ui_left"):
				if currentSelection>0:
					currentSelection-=1
					changeButtonStyle()
					
			if Input.is_action_just_pressed("ui_accept"):
				if currentSelection==0:
					resumeGame()
				elif currentSelection==1:
					_on_exit_btn_pressed()
					
		if Input.is_action_just_pressed("ui_cancel"):
			if visible == false:
				self.visible=true
			else:
				resumeGame()
				
func changeButtonStyle():
	if currentSelection==0:
		buttons[0].add_theme_stylebox_override("normal", highlightStyleBox)
		buttons[0].add_theme_color_override("font_color", Color.BLACK)
		buttons[1].add_theme_stylebox_override("normal", normalStyleBox)
		buttons[1].add_theme_color_override("font_color", Color.WHITE)
	elif currentSelection==1:
		buttons[1].add_theme_stylebox_override("normal", highlightStyleBox)
		buttons[1].add_theme_color_override("font_color", Color.BLACK)
		buttons[0].add_theme_stylebox_override("normal", normalStyleBox)
		buttons[0].add_theme_color_override("font_color", Color.WHITE)
		
func resumeGame():
	currentSelection=0
	changeButtonStyle()
	self.visible=false

func _on_exit_btn_pressed():
	animPlayer.play("levelExit")
	await get_tree().create_timer(.1).timeout
	isExiting=true


func _on_btn_mouse_entered(extra_arg_0):
	currentSelection=extra_arg_0
	changeButtonStyle()
