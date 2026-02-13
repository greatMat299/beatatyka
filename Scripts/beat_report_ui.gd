extends TextureRect

@onready var animPlayer := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var audioPlayer = get_parent().get_parent().get_parent().get_node("MusicPlayer").get_node("AudioPlayer")
	audioPlayer.hasBeat.connect(self.onBeat)

func onBeat():
	print("dj skibidi")
	animPlayer.play("beatAnim")
