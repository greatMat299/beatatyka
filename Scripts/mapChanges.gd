extends Node2D

var midi_player1
var midi_player2
var midi_playerW
var modifierType
var modifierTypeW
var currentPlatform=-1
var currentSpike=-1
@onready var ground := $Ground

func _ready() -> void:
	var midiPlayerName
	
	GameManager.searchForPlatforms()
	GameManager.searchForSpikes()
	GameManager.mapName=self.name
	
	midi_player1 = self.get_node("MusicPlayer").get_node("MidiPlayer")
	midi_player2 = self.get_node("MusicPlayer").get_node("MidiPlayerChannel2")
	midi_playerW = self.get_node("MusicPlayer").get_node("MidiPlayerWarning")
	print(midi_player1.name)
	print(midi_player2.name)
	print(midi_playerW.name)
	
	midi_player1.note_played.connect(self._on_note_played)
	midi_player2.note_played_c2.connect(self._on_note_played)
	#midi_playerW.note_played_w.connect(self._on_warning_note_played)
	
	#midi_player1.note_off.connect(self._on_note_off)
	#midi_player2.note_off.connect(self._on_note_off)
	#midi_playerW.note_off.connect(self._on_note_off)
	
func _on_warning_note_played(note,sender):
	print(str("WARN NOTE: ")+str(note))
	if note>=59&&note<=64:
		if note==59:
			for i in range(0,4):
				if i==0:
					GameManager.platformPrevList[i].enabled = true
					GameManager.platformPrevList[i].get_node("AnimationPlayer").play("showPlatform")
		modifierTypeW=abs(59-note)
		for i in range(0,4):
			if i==modifierTypeW:
				GameManager.platformPrevList[i].enabled = true
				GameManager.platformPrevList[i].get_node("AnimationPlayer").play("showPlatform")
	elif note>=65&&note<=67:
		modifierTypeW=abs(65-note)
		for i in range(0,2):
			if i==modifierTypeW:
				GameManager.spikeList[i].enabled = true
			else:
				GameManager.spikeList[i].enabled = false
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
		
func set_active_platform(index: int):
	if currentPlatform == index:
		return

	if currentPlatform != -1:
		GameManager.platformsList[currentPlatform].enabled = false

	GameManager.platformsList[index].enabled = true
	currentPlatform = index
	
func set_active_spike(index: int):
	if currentSpike == index:
		return

	if currentSpike != -1:
		GameManager.spikeList[currentSpike].enabled = false

	GameManager.spikeList[index].enabled = true
	currentSpike = index
	
func _on_note_played(note, sender):
	print(str("SENDER: ")+str(sender.name))
	var listLength=len(GameManager.platformsList)
	print(note)
	if note==58:
		removeSpikes()
	if note>=59&&note<=64:
		if ground.enabled==false:
			ground.enabled=true
		modifierType=note-59
		set_active_platform(modifierType)
	elif note>=65&&note<=67:
		modifierType=abs(65-note)
		removeSpikes()
		set_active_spike(modifierType)
	elif note>=68&&note<=69:
		pass
	elif note>=70&&note<=73:
		pass
	elif note==74:
		ground.enabled = false
