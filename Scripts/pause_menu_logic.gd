extends Control

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused == false:
			pauseGame()
		else:
			resumeGame()
			
func pauseGame():
	get_tree().paused = true
	self.visible=true

func resumeGame():
	get_tree().paused = false
	self.visible=false


func _on_exit_btn_pressed():
	get_tree().quit()
