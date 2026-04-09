extends Node2D
@onready var tilemap = $LaserTMLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	if get_parent().visible and "Prev" not in get_parent().name:
		for body in $LaserTMLayer/LaserDMGArea2D.get_overlapping_bodies():
			#if body.is_in_group("players"):
			if "Player" in body.name:
				body.take_laser_damage(0)
