extends Node2D

var midi_player1
var midi_player2
var midi_playerW
var midi_playerW2
var modifierType
var modifierTypeW
var currentPlatform=-1
var currentSpike=-1
var currentWarningPlatform := -1
var currentWarningSpike := -1
var playerCount = 3
var rng
@onready var ground := $Ground
@onready var audioStreamPlayer = $AudioStreamPlayer2D

@export var playerScene : PackedScene
@export var playerPos = [0.0,0.0,0.0,0.0]


func _ready() -> void:
	#wybranie pozycji oraz typu powerupa
	rng = RandomNumberGenerator.new()
	GameManager.choose_new_powerup()
	
	audioStreamPlayer.play()
	
	print(GameManager.currentPlayerKeybinds)
	
	print("gay ",GameManager.playerLoadCount)
	
	#do testów mapy
	#GameManager.playerLoadCount=2
	#GameManager.currentPlayerKeybinds=[1,2]
	#GameManager.playerSpriteSheets=[preload("res://Assets/SpriteSheets/sprite1frame.tres"),preload("res://Assets/SpriteSheets/sprite1frame.tres")]

	#dodanie graczy
	for i in range(0,GameManager.playerLoadCount):
		var copy = playerScene.instantiate()
		
		copy.player_id = GameManager.register_player()
		copy.playerKeybindId = GameManager.currentPlayerKeybinds[i]
		copy.name=str("Player")+str(i+1)
		
		copy.playerSpeed=GameManager.currentCharacterSpeeds[i]
		copy.jumpVelocity=GameManager.currentCharacterJumpVels[i]
		copy.attackPower=GameManager.currentCharacterAttackPwr[i]
		copy.dashAttackPower=GameManager.currentCharacterDashAttackPwr[i]
		
		copy.position.x = playerPos[i]
		copy.currentSpriteSheet = GameManager.playerSpriteSheets[i]
		
		var death_area = get_node("DeathArea")
		death_area.body_entered.connect(copy._on_death_area_body_entered)
		add_child(copy)
		
	var midiPlayerName
	
	#wstępne przygotowanie mapy
	GameManager.mapName=self.name
	GameManager.searchForPlatforms()
	GameManager.searchForSpikes()
	
	#wstępne przygotowanie odtwarzaczy MIDI
	midi_player1 = self.get_node("MusicPlayer").get_node("MidiPlayer")
	midi_player2 = self.get_node("MusicPlayer").get_node("MidiPlayerChannel2")
	midi_playerW = self.get_node("MusicPlayer").get_node("MidiPlayerWarning")
	midi_playerW2 = self.get_node("MusicPlayer").get_node("MidiPlayerWarning2")
	
	#połączenie sygnału nut z otwarzaczami
	midi_player1.note_played.connect(self._on_note_played)
	midi_player2.note_played_c2.connect(self._on_note_played)
	midi_playerW.note_played_w.connect(self._on_warning_note_played)
	midi_playerW2.note_played_w.connect(self._on_warning_note_played)
	
func _process(_delta):
	#logika po śmierci wszystkich oprócz jednego gracza
	if GameManager.player_count<=1:
		GameManager.isGamePlaying=false
		
	if GameManager.hasStartSeqFinished==true and audioStreamPlayer.playing==false:
		audioStreamPlayer.play()
	
func _on_warning_note_played(note,sender):
	#aktywowanie platform ostrzegawczych
	if note>=59&&note<=64:
		modifierTypeW=abs(59-note)
		call_deferred("_apply_warning_platform", modifierTypeW)
	#aktywowanie kolców ostrzegawczych
	elif note>=65&&note<=67:
		modifierTypeW=abs(65-note)
		call_deferred("_apply_warning_spike", modifierTypeW)
	#potem będzie deszcz i trap platformy ale nie są zaimplementowane
		
#usunięcie wszystkich aktywnych kolców
func removeSpikes():
	if currentSpike!=-1:
		GameManager.spikeList[currentSpike].enabled = false
		currentSpike=-1
	
#funkcja mówi sama za siebie	
func _apply_warning_platform(index: int):
	set_active_platform(index, true)

#funkcja mówi sama za siebie
func _apply_warning_spike(index: int):
	set_active_spike(index, true)
		
#aktywowanie danej sekwencji kolców
func set_active_spike(index: int, isWarning: bool):
	if isWarning:
		if currentWarningSpike == index:
			return

		#jeżeli jakaś sekwencja ostrzegawcza jest to ją usuwa
		if currentWarningSpike != -1: 
			GameManager.spikePrevList[currentWarningSpike].enabled = false

		#pokazanie sekwencji ostrzegawczej
		GameManager.spikePrevList[index].enabled = true
		GameManager.spikePrevList[index].get_node("AnimationPlayer").play("showSpikes")

		currentWarningSpike = index
	else:
		if currentSpike == index:
			return

		#jak wyżej, usuwa wcześniej aktywne kolce
		if currentSpike != -1:
			GameManager.spikeList[currentSpike].enabled = false

		GameManager.spikeList[index].enabled = true
		currentSpike = index
		
func set_active_platform(index: int, isWarning: bool):
	if isWarning:
		if currentWarningPlatform == index:
			return

		#jeżeli jakaś platforma ostrzegawcza jest to ją usuwa
		if currentWarningPlatform != -1:
			GameManager.platformPrevList[currentWarningPlatform].enabled = false

		GameManager.platformPrevList[index].enabled = true
		GameManager.platformPrevList[index].get_node("AnimationPlayer").play("showPlatform")

		currentWarningPlatform = index
	else:
		if currentPlatform == index:
			return

		#jeżeli jakaś poprzednia platforma jest to ją usuwa
		if currentPlatform != -1:
			GameManager.platformsList[currentPlatform].enabled = false

		GameManager.platformsList[index].enabled = true
		currentPlatform = index
	
func _on_note_played(note, sender):
	if currentWarningPlatform != -1:
		GameManager.platformPrevList[currentWarningPlatform].enabled = false
		currentWarningPlatform = -1
	var listLength=len(GameManager.platformsList)
	print(note)
	
	#dodatkowe nuty
	if note==57:
		GameManager.isGamePlaying=false #koniec gry
	if note==58:
		removeSpikes()
		
	#normalne nuty
	if note>=59&&note<=64: #platforma
		if ground.enabled==false:
			ground.enabled=true
		modifierType=note-59
		set_active_platform(modifierType, false)
	elif note>=65&&note<=67: #kolce
		modifierType=abs(65-note)
		removeSpikes()
		set_active_spike(modifierType,false)
	#elif note>=68&&note<=69: #deszcz
		#pass
	#elif note>=70&&note<=73: #laser
		#pass
	elif note==74: #usunięcie ziemi
		ground.enabled = false

#wybranie nowego powerupa kiedy skończy się cooldown
func _on_powerup_cooldown_timeout():
	GameManager.choose_new_powerup()
