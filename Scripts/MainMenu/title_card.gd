extends Control

@onready var hiddenLabel = $HiddenLabel
@onready var dingSfx = $DingSFX
@onready var vboxContainer = $VBoxContainer
var textInserted=""
var cheatCode1="jacojajco"
var enabled=true
var isOnStartLabel=false

func checkForCheatCode(text):
	if text.to_lower()==cheatCode1:
		dingSfx.play()
		hiddenLabel.visible=true
		GameManager.isExtraMapEnabled=true

func _input(event):
	if GameManager.hasPlayedRound==true:
		enabled=false
		visible=false
	else:
		if event is InputEventMouseButton and event.pressed and isOnStartLabel:
			enabled=false
			visible=false
		if event is InputEventKey and event.pressed and enabled:
			if not event.echo:
				if event.as_text()=="Enter":
					enabled=false
					visible=false
				textInserted+=event.as_text()
				checkForCheatCode(textInserted)

func _on_v_box_container_mouse_entered():
	isOnStartLabel=true
	vboxContainer.modulate = Color(0.895, 0.895, 0.895, 1.0)


func _on_v_box_container_mouse_exited():
	isOnStartLabel=false
	vboxContainer.modulate = Color(1.0, 1.0, 1.0, 1.0)
