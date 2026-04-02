extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().visible==true and "NC" not in name:
		for body in $TileMapLayer/BombArea2D.get_overlapping_bodies():
			#if body.is_in_group("players"):
			if "Player" in body.name:
				body.take_laser_damage(50)
				queue_free()
