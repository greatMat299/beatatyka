extends Node2D

var midi_player1
var midi_player2
var midi_playerW
var midi_playerW2
var modifierType
var modifierTypeW
var currentPlatform=-1
var currentSpike=-1
var currentBombs=-1
var currentLaser=-1
var currentWarningPlatform = -1
var currentWarningSpike = -1
var currentWarningBomb = -1
var currentWarningLaser = -1
var playerCount
var rng
var warningSpikeBySender = {}
var warningPlatformBySender = {}
var warningBombBySender = {}
var warningLaserBySender = {}
@onready var ground := $Ground
@onready var audioStreamPlayer = $AudioStreamPlayer2D

@export var playerScene : PackedScene
@export var playerPos = [0.0,0.0,0.0,0.0]


func _ready() -> void:
	#wybranie pozycji oraz typu powerupa
	rng = RandomNumberGenerator.new()
	GameManager.choose_new_powerup()
	
	GameManager.isGamePlaying==true
	
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
		GameManager.addPlayerLife()
		add_child(copy)
		
	var midiPlayerName
	
	#wstępne przygotowanie mapy
	GameManager.mapName=self.name
	GameManager.searchForLasers()
	GameManager.searchForPlatforms()
	GameManager.searchForSpikes()
	GameManager.searchForBombs()
	
	
	#wstępne przygotowanie odtwarzaczy MIDI
	midi_player1 = self.get_node("MusicPlayer").get_node("MidiPlayer")
	midi_player2 = self.get_node("MusicPlayer").get_node("MidiPlayerChannel2")
	midi_playerW = self.get_node("MusicPlayer").get_node("MidiPlayerWarning")
	midi_playerW2 = self.get_node("MusicPlayer").get_node("MidiPlayerWarning2")
	
	#połączenie sygnału nut z otwarzaczami
	midi_player1.note_played.connect(self._on_note_played)
	midi_player2.note_played_c2.connect(self._on_note_played)
	midi_playerW.note_played_w.connect(self._on_warning_note_played)
	midi_playerW2.note_played_w2.connect(self._on_warning_note_played)
	
func _process(_delta):
	#logika po śmierci wszystkich oprócz jednego gracza
	if GameManager.player_count<=0:
		GameManager.isGamePlaying=false
		
	if GameManager.hasStartSeqFinished==true and audioStreamPlayer.playing==false:
		audioStreamPlayer.play()
	
func _on_warning_note_played(note,sender):
	if GameManager.isGamePlaying==true:
		#aktywowanie platform ostrzegawczych
		if note>=59&&note<=64:
			modifierTypeW=abs(59-note)
			call_deferred("_apply_warning_platform", modifierTypeW, sender)
		#aktywowanie kolców ostrzegawczych
		elif note>=65 && note<=67:
			modifierTypeW = abs(65-note)
			call_deferred("_apply_warning_spike", modifierTypeW, sender)
		elif note>=68 && note<=69:
			modifierTypeW = abs(68-note)
			call_deferred("_apply_warning_bomb", modifierTypeW, sender)
		elif note>=70 && note<=73:
			modifierTypeW = abs(70-note)
			call_deferred("_apply_warning_laser", modifierTypeW, sender)
		#potem będzie deszcz i trap platformy ale nie są zaimplementowane
		
#usunięcie wszystkich aktywnych kolców
func removeSpikes():
	if currentSpike!=-1:
		GameManager.spikeList[currentSpike].visible = false
		currentSpike=-1
		
func removeBombs():
	if currentBombs!=-1:
		GameManager.bombList[currentBombs].visible = false
		currentBombs=-1
		
func removeLaser():
	if currentLaser!=-1:
		GameManager.laserList[currentLaser].visible = false
		currentLaser=-1
	
#funkcja mówi sama za siebie	
func _apply_warning_platform(index: int,sender):
	set_active_platform(index, true, sender)

#funkcja mówi sama za siebie
func _apply_warning_spike(index: int,sender):
	set_active_spike(index, true, sender)

#funkcja mówi sama za siebie
func _apply_warning_bomb(index: int,sender):
	set_active_bomb(index, true, sender)
	
func _apply_warning_laser(index: int,sender):
	set_active_laser(index, true, sender)	
		
#aktywowanie danej sekwencji kolców
func set_active_spike(index: int, isWarning: bool, sender = null):
	if isWarning:
		if sender == null:
			return
			
		if warningSpikeBySender.has(sender):
			var prev = warningSpikeBySender[sender]
			GameManager.spikePrevList[prev].visible = false

		GameManager.spikePrevList[index].visible = true
		GameManager.spikePrevList[index].get_node("AnimationPlayer").play("showSpikes")

		warningSpikeBySender[sender] = index

	else:
		if currentSpike == index:
			return

		if currentSpike != -1:
			GameManager.spikeList[currentSpike].visible = false

		GameManager.spikeList[index].visible = true
		currentSpike = index
		
func set_active_bomb(index: int, isWarning: bool, sender = null):
	if isWarning:
		if sender == null:
			return
			
		if warningBombBySender.has(sender):
			var prev = warningBombBySender[sender]
			GameManager.bombPrevList[prev].visible = false

		GameManager.bombPrevList[index].visible = true
		GameManager.bombPrevList[index].get_node("AnimationPlayer").play("showBombs")

		warningBombBySender[sender] = index

	else:
		if currentBombs == index:
			return

		if currentBombs != -1:
			GameManager.bombList[currentBombs].visible = false

		GameManager.bombList[index].visible = true
		currentBombs = index
		
func set_active_laser(index: int, isWarning: bool, sender = null):
	if isWarning:
		if sender == null:
			return
			
		if warningLaserBySender.has(sender):
			var prev = warningLaserBySender[sender]
			GameManager.laserPrevList[prev].visible = false

		GameManager.laserPrevList[index].visible = true
		GameManager.laserPrevList[index].get_node("AnimationPlayer").play("showLaser")

		warningLaserBySender[sender] = index

	else:
		if currentLaser == index:
			return

		if currentLaser != -1:
			GameManager.laserList[currentLaser].visible = false

		GameManager.laserList[index].visible = true
		currentLaser = index
		
func set_active_platform(index: int, isWarning: bool, sender = null):
	if isWarning:
		if sender == null:
			return

		if warningPlatformBySender.has(sender):
			var prev = warningPlatformBySender[sender]
			GameManager.platformPrevList[prev].enabled = false

		GameManager.platformPrevList[index].enabled = true
		GameManager.platformPrevList[index].get_node("AnimationPlayer").play("showPlatform")

		warningPlatformBySender[sender] = index

	else:
		if currentPlatform == index:
			return

		if currentPlatform != -1:
			GameManager.platformsList[currentPlatform].enabled = false

		GameManager.platformsList[index].enabled = true
		currentPlatform = index
	
func _on_note_played(note, sender):
	print("uwu ",note)
	if GameManager.isGamePlaying==true:
		#if currentWarningPlatform != -1:
			#GameManager.platformPrevList[currentWarningPlatform].enabled = false
			#currentWarningPlatform = -1
		var listLength=len(GameManager.platformsList)
		print(note)
		
		if warningPlatformBySender.has(sender):
			var idx = warningPlatformBySender[sender]
			GameManager.platformPrevList[idx].enabled = false
			warningPlatformBySender.erase(sender)
			
		if warningSpikeBySender.has(sender):
			var idx = warningSpikeBySender[sender]
			GameManager.spikePrevList[idx].visible = false
			warningSpikeBySender.erase(sender)
			
		if warningBombBySender.has(sender):
			print("disabling bomb")
			var idx = warningBombBySender[sender]
			var bomb = GameManager.bombPrevList[idx]

			bomb.get_node("AnimationPlayer").stop()
			bomb.visible = false

			warningBombBySender.erase(sender)
			
		if warningLaserBySender.has(sender):
			var idx = warningLaserBySender[sender]
			GameManager.laserPrevList[idx].visible = false
			warningLaserBySender.erase(sender)
		
		#dodatkowe nuty
		if note==55:
			removeLaser()
		elif note==56:
			removeBombs()
		elif note==57:
			GameManager.isGamePlaying=false #koniec gry
		elif note==58:
			removeSpikes()
			
		#normalne nuty
		if note>=59&&note<=64: #platforma
			if ground.enabled==false:
				ground.enabled=true
			modifierType=note-59
			set_active_platform(modifierType, false,sender)
		elif note>=65&&note<=67: #kolce
			modifierType=abs(65-note)
			removeSpikes()
			set_active_spike(modifierType,false,sender)
		elif note>=68&&note<=69:
			modifierType=abs(68-note)
			removeBombs()
			set_active_bomb(modifierType,false,sender)
		elif note>=70&&note<=73: #laser
			modifierType=abs(70-note)
			removeLaser()
			set_active_laser(modifierType,false,sender)
		elif note==74: #zmiana ziemii
			get_node("Ground2").enabled=true
			ground.enabled = false

#wybranie nowego powerupa kiedy skończy się cooldown
func _on_powerup_cooldown_timeout():
	GameManager.choose_new_powerup()
