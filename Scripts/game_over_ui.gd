extends Control

@onready var animPlayer = $AnimationPlayer
var isPlaying=false

func _process(_delta):	
	#pokazanie menu końca gry po zakończeniu gry
	if GameManager.player_count==0 or GameManager.isGamePlaying==false and GameManager.hasStartSeqFinished==true:
		self.visible=true
		if isPlaying==false:
			animPlayer.play("showEndGame")
			isPlaying=true
			get_parent().get_node("GameplayNodes").visible=false
			get_parent().get_node("BlurFill").visible=true
