extends Control

var currentSongPreview
var fade_tween
var currentSongMapIndex=0
var enabled=false
@onready var songPreviewPlayer = $SongPreview

var songPreviews = [
	preload("res://Assets/Sound/songPreviews/crabRavePreview.mp3"),
	preload("res://Assets/Sound/songPreviews/chromaticallyPreview.mp3"),
	preload("res://Assets/Sound/songPreviews/ghosts_n_stuff_preview.mp3"),
	preload("res://Assets/Sound/songPreviews/dashstarPreview.mp3"),
	preload("res://Assets/Sound/songPreviews/its_you_preview.mp3"),
	preload("res://Assets/Sound/songPreviews/its_you_preview.mp3")
]

var songMaps = [
	"res://Scenes/map1.tscn",
	"res://Scenes/map1.tscn", #tu inna mapa
	"res://Scenes/map1.tscn", #tu inna mapa
	"res://Scenes/map1.tscn", #tu inna mapa
	"res://Scenes/map1.tscn", #tu inna mapa
	"res://Scenes/map1.tscn" #tu inna mapa
]

func _process(_delta):
	if enabled:
		var progress=[]
		ResourceLoader.load_threaded_get_status(songMaps[currentSongMapIndex],progress)
		if progress[0]==1:
			var packedScene = ResourceLoader.load_threaded_get(songMaps[currentSongMapIndex])
			get_tree().change_scene_to_packed(packedScene)

func _on_song_button_pressed(extra_arg_0):
	if enabled:
		currentSongMapIndex=extra_arg_0
		ResourceLoader.load_threaded_request(songMaps[currentSongMapIndex])


func _on_song_button_mouse_entered(extra_arg_0):
	if enabled:
		if fade_tween:
			fade_tween.kill()
			fade_tween = null
			
		songPreviewPlayer.stop() # stop previous preview
		songPreviewPlayer.volume_db = 0  # reset volume
		songPreviewPlayer.stream = songPreviews[extra_arg_0]
		songPreviewPlayer.play()


func _on_song_button_mouse_exited():
	if enabled:
		if fade_tween:
			fade_tween.kill()
			
		fade_tween = create_tween()
		fade_tween.tween_property(songPreviewPlayer, "volume_db", -80, 0.5)
		fade_tween.tween_callback(songPreviewPlayer.stop)
