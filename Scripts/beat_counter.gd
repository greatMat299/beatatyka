extends AudioStreamPlayer2D

@export var bpm : int = 120
var song_position = 0.0
var song_position_in_beats
var sec_per_beat = 0.0
var beats_before_start = 0
var last_reported_beat = 0
var mesaure = 1
var mesaures = 4

func _ready():
	sec_per_beat = 60.0 / bpm

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if GameManager.isGamePlaying==true:
		#print(song_position_in_beats)
		song_position = get_playback_position()+AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat) + beats_before_start)
		reportBeat()
	else:
		self.stop()
	
func reportBeat():
	if last_reported_beat < song_position_in_beats:
		if mesaure > mesaures:
			mesaure = 1
		last_reported_beat = song_position_in_beats
		mesaure += 1
		#print("beat")
