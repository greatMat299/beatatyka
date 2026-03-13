extends Control

var mapPath=""
var hasMapLoadingActivated=false
@onready var animPlayer = $AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible==true and hasMapLoadingActivated==false:
		animPlayer.play("showLoading")
		hasMapLoadingActivated=true
		ResourceLoader.load_threaded_request(mapPath)
		
	var progress=[]
	ResourceLoader.load_threaded_get_status(mapPath,progress)
	if progress[0]==1:
		var packedScene = ResourceLoader.load_threaded_get(mapPath)
		get_tree().change_scene_to_packed(packedScene)
