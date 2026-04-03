extends Control

@onready var hiddenLabel = $HiddenLabel
@onready var dingSfx = $DingSFX
var textInserted=""
var cheatCode1="jacojajco"
var enabled=true

func _input(event):
	if GameManager.hasPlayedRound==true:
		enabled=false
		visible=false
	else:
		if event is InputEventKey and event.pressed and enabled:
			if not event.echo:
				if event.as_text()=="Enter":
					enabled=false
					visible=false
				textInserted+=event.as_text()
				if textInserted.to_lower()==cheatCode1:
					dingSfx.play()
					hiddenLabel.visible=true
					GameManager.isExtraMapEnabled=true
