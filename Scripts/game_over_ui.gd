extends CenterContainer

func _process(_delta):	
	#pokazanie menu końca gry po zakończeniu gry
	if GameManager.player_count==0 or GameManager.isGamePlaying==false:
		self.visible=true
		get_parent().get_node("GameplayNodes").visible=false
		get_parent().get_node("BlurFill").visible=true
