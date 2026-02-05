extends Node2D

var midi_player1
var midi_player2
var midi_playerW
var modifierType
var modifierTypeW
var currentPlatform=-1
var currentSpike=-1
var currentWarningPlatform := -1
var currentWarningSpike := -1
@onready var ground := $Ground

func _ready() -> void:
	var midiPlayerName
	
	GameManager.searchForPlatforms()
	GameManager.searchForSpikes()
	GameManager.mapName=self.name
	
	midi_player1 = self.get_node("MusicPlayer").get_node("MidiPlayer")
	midi_player2 = self.get_node("MusicPlayer").get_node("MidiPlayerChannel2")
	midi_playerW = self.get_node("MusicPlayer").get_node("MidiPlayerWarning")
	#print(midi_player1.name)
	#print(midi_player2.name)
	#print(midi_playerW.name)
	
	midi_player1.note_played.connect(self._on_note_played)
	midi_player2.note_played_c2.connect(self._on_note_played)
	midi_playerW.note_played_w.connect(self._on_warning_note_played)
	
func _process(_delta):
	if GameManager.player_count==1:
		#print("NOOOOOO")
		GameManager.isGamePlaying=false
	
func _on_warning_note_played(note,sender):
	print(str("warn: ")+str(note))
	if note>=59&&note<=64:
		modifierTypeW=abs(59-note)
		call_deferred("_apply_warning_platform", modifierTypeW)
	elif note>=65&&note<=67:
		modifierTypeW=abs(65-note)
		call_deferred("_apply_warning_spike", modifierTypeW)
	#elif note>=68&&note<=69:
		#pass
	#elif note>=70&&note<=73:
		#pass
	#elif note==74:
		#self.get_node("Ground").enabled = false
		
func removeSpikes():
	if currentSpike!=-1:
		GameManager.spikeList[currentSpike].enabled = false
		currentSpike=-1
		
func _apply_warning_platform(index: int):
	set_active_platform(index, true)
	
func _apply_warning_spike(index: int):
	set_active_spike(index, true)
		
func set_active_spike(index: int, isWarning: bool):
	if isWarning:
		if currentWarningSpike == index:
			return

		if currentWarningSpike != -1:
			GameManager.spikePrevList[currentWarningSpike].enabled = false

		GameManager.spikePrevList[index].enabled = true
		GameManager.spikePrevList[index].get_node("AnimationPlayer").play("showSpikes")

		currentWarningSpike = index
	else:
		if currentSpike == index:
			return

		if currentSpike != -1:
			GameManager.spikeList[currentSpike].enabled = false

		GameManager.spikeList[index].enabled = true
		currentSpike = index
		
func set_active_platform(index: int, isWarning: bool):
	if isWarning:
		if currentWarningPlatform == index:
			return

		if currentWarningPlatform != -1:
			GameManager.platformPrevList[currentWarningPlatform].enabled = false

		GameManager.platformPrevList[index].enabled = true
		GameManager.platformPrevList[index].get_node("AnimationPlayer").play("showPlatform")

		currentWarningPlatform = index
	else:
		if currentPlatform == index:
			return

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
	if note==58:
		removeSpikes()
	if note>=59&&note<=64:
		if ground.enabled==false:
			ground.enabled=true
		modifierType=note-59
		set_active_platform(modifierType, false)
	elif note>=65&&note<=67:
		modifierType=abs(65-note)
		removeSpikes()
		set_active_spike(modifierType,false)
	elif note>=68&&note<=69:
		pass
	elif note>=70&&note<=73:
		pass
	elif note==74:
		ground.enabled = false
