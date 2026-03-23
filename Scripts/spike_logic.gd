extends Node2D
@onready var tilemap = $TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if "NC" not in name:
		get_parent().visibility_changed.connect(_on_visibility_changed)
		_on_visibility_changed()
	
func _on_visibility_changed():
	tilemap.set_deferred("collision_enabled", get_parent().visible)
