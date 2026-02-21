extends Area2D

var isNotePlaying=false
var windowX
var noteSpeed=100.0

func _ready():
	windowX = get_window().size.x
	position.y = 70

#przesuwanie obiektu nuty
func _process(delta):
	if isNotePlaying==true:
		self.position.x+=noteSpeed*delta
		
	if self.position.x>=1500.0:
		queue_free()
