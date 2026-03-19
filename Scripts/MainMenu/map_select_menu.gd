extends Control

var currentSongPreview
var fade_tween
var zoom_tween
var currentSongMapIndex=0
var enabled=false
var mapBackgrounds=[]
var songButtons=[]
var currentKeyboardMapIndex=0
@onready var songPreviewPlayer = $SongPreview
@onready var selectBorder = $MarginContainer/selectBorder
@onready var characterSelection = $"../CharacterSelection"
@onready var loadingScreen = $"../LoadingScreen"
@onready var animPlayer = $AnimationPlayer
@onready var menuSelectSfx = $"../MenuSelectSfx"
@onready var menuBackSfx = $"../MenuBackSfx"
@onready var menuSwipeSfx = $"../MenuSwipeSfx"

var songPreviews = [
	preload("res://Assets/Sound/songPreviews/crabRavePreview.mp3"),
	preload("res://Assets/Sound/songPreviews/chromaticallyPreview.mp3"),
	preload("res://Assets/Sound/songPreviews/dead_man_walking_preview.mp3"),
	preload("res://Assets/Sound/songPreviews/ghosts_n_stuff_preview.mp3"),
	preload("res://Assets/Sound/songPreviews/dashstarPreview.mp3"),
	preload("res://Assets/Sound/songPreviews/its_you_preview.mp3")
]

var songMaps = [
	"res://Scenes/map1.tscn",
	"res://Scenes/map2.tscn", #tu inna mapa
	"res://Scenes/map1.tscn", #tu inna mapa
	"res://Scenes/map1.tscn", #tu inna mapa
	"res://Scenes/map1.tscn", #tu inna mapa
	"res://Scenes/map1.tscn" #tu inna mapa
]

func _process(_delta):
	if enabled:
		if len(mapBackgrounds)==0:
			var hboxNum=0
			for i in range(0,6):
				if i>=3:
					hboxNum=2
				else:
					hboxNum=1
				mapBackgrounds.append(get_node("MarginContainer/VBoxContainer/HBoxContainer"+str(hboxNum)+"/SongButton"+str(i+1)+"/MapBackground"))
		
		if len(songButtons)==0:
			var hboxNum=0
			for i in range(0,6):
				if i>=3:
					hboxNum=2
				else:
					hboxNum=1
				songButtons.append(get_node("MarginContainer/VBoxContainer/HBoxContainer"+str(hboxNum)+"/SongButton"+str(i+1)))
				if i==5:
					selectBorder.global_position = songButtons[0].global_position
					selectBorder.size = songButtons[0].size
					playPreview(0)
					
		if Input.is_action_just_pressed("ui_right"):
			stopPreview(currentKeyboardMapIndex)
			if currentKeyboardMapIndex>-1 and currentKeyboardMapIndex<5:
				currentKeyboardMapIndex+=1
				if songButtons[currentKeyboardMapIndex].disabled==true:
					currentKeyboardMapIndex-=1
			changeButtonPosition(currentKeyboardMapIndex)
			playPreview(currentKeyboardMapIndex)
			
		if Input.is_action_just_pressed("ui_left"):
			stopPreview(currentKeyboardMapIndex)
			if currentKeyboardMapIndex<6 and currentKeyboardMapIndex>0:
				currentKeyboardMapIndex-=1
				if songButtons[currentKeyboardMapIndex].disabled==true:
					currentKeyboardMapIndex+=1
			changeButtonPosition(currentKeyboardMapIndex)
			playPreview(currentKeyboardMapIndex)
			
		if Input.is_action_just_pressed("ui_down"):
			stopPreview(currentKeyboardMapIndex)
			match currentKeyboardMapIndex:
				0:
					currentKeyboardMapIndex=3
				1:
					currentKeyboardMapIndex=4
				2:
					currentKeyboardMapIndex=5
			if songButtons[currentKeyboardMapIndex].disabled==true:
				currentKeyboardMapIndex-=3
			else:
				changeButtonPosition(currentKeyboardMapIndex)
				playPreview(currentKeyboardMapIndex)
			
		if Input.is_action_just_pressed("ui_up"):
			stopPreview(currentKeyboardMapIndex)
			match currentKeyboardMapIndex:
				3:
					currentKeyboardMapIndex=0
				4:
					currentKeyboardMapIndex=1
				5:
					currentKeyboardMapIndex=2
			if songButtons[currentKeyboardMapIndex].disabled==true:
				currentKeyboardMapIndex+=3
			else:
				changeButtonPosition(currentKeyboardMapIndex)
				playPreview(currentKeyboardMapIndex)
			
		if Input.is_action_just_pressed("ui_accept"):
			if songButtons[currentKeyboardMapIndex].disabled==false:
				loadGameMap(currentKeyboardMapIndex)
				
		if Input.is_action_just_pressed("ui_cancel"):
			menuBackSfx.play()
			for i in range(0,4):
				characterSelection.arePlayersReady[i]=false
			await get_tree().create_timer(0.03).timeout
			songPreviewPlayer.stop()
			visible=false
			characterSelection.enabled=true
			characterSelection.isGameReady=false
			characterSelection.isGameLaunching=false
			characterSelection.visible=true
			currentKeyboardMapIndex=0
			enabled=false

func playPreview(index):
	menuSwipeSfx.play()
	await get_tree().create_timer(0.03).timeout
	
	if fade_tween:
		fade_tween.kill()
		fade_tween = null
		
	zoom_tween = create_tween()
	zoom_tween.tween_property(mapBackgrounds[index], "scale", Vector2(1.02, 1.02), 0.15)
	
	changeButtonPosition(index)
	
	songPreviewPlayer.stop() # stop previous preview
	songPreviewPlayer.volume_db = 0  # reset volume
	songPreviewPlayer.stream = songPreviews[index]
	songPreviewPlayer.play()
	
func stopPreview(index):
	if fade_tween:
		fade_tween.kill()
		fade_tween=null
			
	if zoom_tween:
		zoom_tween.kill()
		zoom_tween=null
			
	#selectBorder.visible=false
		
	zoom_tween = create_tween()
	zoom_tween.tween_property(mapBackgrounds[index], "scale", Vector2(1, 1), 0.15)
		
	fade_tween = create_tween()
	fade_tween.tween_property(songPreviewPlayer, "volume_db", -80, 0.5)
	fade_tween.tween_callback(songPreviewPlayer.stop)

func loadGameMap(index):
	loadingScreen.mapPath = songMaps[index]
	animPlayer.play("levelMenuDissapear")
	loadingScreen.visible=true
	#self.visible=false
	
	
func _on_song_button_pressed(extra_arg_0):
	if enabled:
		currentSongMapIndex=extra_arg_0
		loadGameMap(currentSongMapIndex)
		

func changeButtonPosition(index):
	selectBorder.global_position = songButtons[index].global_position
	selectBorder.size = songButtons[index].size

func _on_song_button_mouse_entered(extra_arg_0):
	if enabled and len(songButtons)>0:
		if songButtons[extra_arg_0].disabled==false:
			currentKeyboardMapIndex=extra_arg_0
			playPreview(extra_arg_0)
		
		
		


func _on_song_button_mouse_exited(extra_arg_0):
	if enabled:
		stopPreview(extra_arg_0)
