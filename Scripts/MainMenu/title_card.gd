extends Control

@onready var hiddenLabel = $HiddenLabel
var textInserted=""
var cheatCode1="jacojajco"
var enabled=true

func _input(event):
	if event is InputEventKey and event.pressed and enabled:
		if not event.echo:
			if event.as_text()=="Enter":
				enabled=false
				visible=false
			textInserted+=event.as_text()
			if textInserted.to_lower()==cheatCode1:
				hiddenLabel.visible=true
