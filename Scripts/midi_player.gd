extends MidiPlayer

signal note_played(note)
signal note_played_c2(note)
signal note_off

#przygotowanie muzyki oraz sygnału
func _ready():
	self.note.connect(my_note_callback)
	self.play()
	
#pauzowanie muzyki kiedy gra się kończy (np. śmierć)
func _process(delta):
	if GameManager.isGamePlaying==false:
		self.stop()
		pass

#wysyłanie informacji o obecnej nucie do innych skryptów
func my_note_callback(event, track):
	if GameManager.isGamePlaying==true:
		if event['subtype'] == MIDI_MESSAGE_NOTE_ON: 
			#print(str(event['note'])+" "+str(event['channel']))
			if self.name=="MidiPlayer":
				emit_signal("note_played", event['note'])
			elif self.name=="MidiPlayerChannel2":
				emit_signal("note_played_c2", event['note'])	
		elif event['subtype'] == MIDI_MESSAGE_NOTE_OFF:
			#print("and off")
			note_off.emit()
