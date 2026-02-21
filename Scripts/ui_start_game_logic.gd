extends Control

@onready var animPlayer = $AnimationPlayer

func _ready():
	animPlayer.play("getReadyAnim")


func _on_animation_player_animation_finished(anim_name):
	get_parent().get_node("GameplayNodes").visible=true
	GameManager.isGamePlaying=true
	GameManager.hasStartSeqFinished=true
