extends Label

var midi_player
var modifierType
var mapName=GameManager.mapName

func _ready() -> void:
	var midiPlayerName
	if self.name=="Label":
		midiPlayerName="MidiPlayer"
	else:
		midiPlayerName="MidiPlayerChannel2"
	midi_player = get_tree().get_root().get_node(mapName).get_node("MusicPlayer").get_node(midiPlayerName) # exact path in the tree
	print(midi_player.name)
	
	# Connect the signal to a local function
	if self.name=="Label":
		midi_player.note_played.connect(self._on_note_played)
	else:
		midi_player.note_played_c2.connect(self._on_note_played)
	midi_player.note_off.connect(self._on_note_off)
	
	print(midi_player)
	
func _on_note_off():
	self.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
	text = "Note off"
	
# This function MUST exist!
func _on_note_played(note,sender):
	var type=""
	if note==59:
		self.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
		type="normal"
	if note>=60&&note<=64:
		self.add_theme_color_override("font_color", Color(1, 0.5, 0))
		type="change platform"
	elif note>=65&&note<=67:
		self.add_theme_color_override("font_color", Color(0.241, 0.787, 0.0, 1.0))
		type="ground spike"
	elif note>=68&&note<=69:
		self.add_theme_color_override("font_color", Color(1.0, 0.456, 0.555, 1.0))
		type="toxic rain"
	elif note>=70&&note<=73:
		self.add_theme_color_override("font_color", Color(0.394, 0.671, 1.0, 1.0))
		type="trap platform"
	elif note==74:
		self.add_theme_color_override("font_color", Color(0.394, 0.671, 1.0, 1.0))
		type="no ground"
	text = "Note played: " + str(note)+" "+str(type)
