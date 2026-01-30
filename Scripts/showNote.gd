extends Label

var midi_player

func _ready() -> void:
	midi_player = get_tree().get_root().get_child(0).get_child(4).get_child(0) # exact path in the tree
	
	# Connect the signal to a local function
	midi_player.note_played.connect(self._on_note_played)
	
	print(midi_player)

# This function MUST exist!
func _on_note_played(note):
	# Update the Label text when a note is played
	text = "Note played: " + str(note)
	if note>59:
		self.add_theme_color_override("font_color", Color(1, 0.5, 0))
