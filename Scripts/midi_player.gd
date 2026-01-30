extends MidiPlayer

signal note_played(note)

func _ready():
	self.note.connect(my_note_callback)
	self.play()

func my_note_callback(event, track):
	if event['subtype'] == MIDI_MESSAGE_NOTE_ON:  # note on
		print(event['note'])
		emit_signal("note_played", event['note'])  # FIX: use event['note']
	elif event['subtype'] == MIDI_MESSAGE_NOTE_OFF:
		pass
