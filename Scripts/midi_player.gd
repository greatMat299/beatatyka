extends MidiPlayer

signal note_played(note, sender)
signal note_played_c2(note, sender)
signal note_played_w(note, sender)
signal note_played_wc(note, sender) #warningcatch
signal note_off
var ignore_events := false

func _ready():
	note.connect(my_note_callback)
	play()
	
func _process(_delta):
	#zatrzymanie odtwarzacza MIDI jeżeli gra się skończy
	if GameManager.isGamePlaying==false or GameManager.isSongOver==true:
		stop()

#to miało być do pauzy odtwarzacza ale to średnio działa
#func _notification(what):
	#if what == NOTIFICATION_PAUSED:
		#ignore_events = true
	#elif what == NOTIFICATION_UNPAUSED:
		#ignore_events = false

func my_note_callback(event, track):
	if ignore_events:
		return

	#wysyłanie obecnie zagranej nuty
	if event["subtype"] == MIDI_MESSAGE_NOTE_ON:
		match name:
			"MidiPlayer":
				note_played.emit(event["note"], self)
			"MidiPlayerChannel2":
				note_played_c2.emit(event["note"], self)
			"MidiPlayerWarning":
				note_played_w.emit(event["note"], self)
			"MidiPlayerCatcher":
				note_played_wc.emit(event["note"], self)
	elif event["subtype"] == MIDI_MESSAGE_NOTE_OFF:
		note_off.emit()
