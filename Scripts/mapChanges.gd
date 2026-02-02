extends Node2D

var midi_player1
var midi_player2
var modifierType

func _ready() -> void:
	var midiPlayerName
	midi_player1 = self.get_node("MusicPlayer").get_node("MidiPlayer")
	midi_player2 = self.get_node("MusicPlayer").get_node("MidiPlayerChannel2")
	print(midi_player1.name)
	print(midi_player2.name)
	
	midi_player1.note_played.connect(self._on_note_played)
	midi_player2.note_played_c2.connect(self._on_note_played)
	
	midi_player1.note_off.connect(self._on_note_off)
	midi_player2.note_off.connect(self._on_note_off)
	
func _on_note_off():
	for i in range(0,4):
		GameManager.platformsList[i].enabled = false
	for i in range(0,2):
		GameManager.spikeList[i].enabled = false
	GameManager.platformsList[0].enabled = true
	self.get_node("Ground").enabled = true
	
func _on_note_played(note):
	print(note)
	if note>=60&&note<=64:
		modifierType=abs(59-note)
		for i in range(0,4):
			if i==modifierType:
				GameManager.platformsList[i].enabled = true
			else:
				GameManager.platformsList[i].enabled = false
	elif note>=65&&note<=67:
		modifierType=abs(65-note)
		for i in range(0,2):
			if i==modifierType:
				GameManager.spikeList[i].enabled = true
			else:
				GameManager.spikeList[i].enabled = false
	elif note>=68&&note<=69:
		pass
	elif note>=70&&note<=73:
		pass
	elif note==74:
		self.get_node("Ground").enabled = false
