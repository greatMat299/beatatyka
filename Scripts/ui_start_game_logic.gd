extends Control

@onready var animPlayer = $AnimationPlayer
@onready var startSFX = $startSFX

func _ready():
	await get_tree().process_frame
	animPlayer.speed_scale = GameManager.levelBPM / 120.0
	startSFX.pitch_scale = GameManager.levelBPM / 120.0
	animPlayer.play("getReadyAnim")


func _on_animation_player_animation_finished(anim_name):
	get_parent().get_node("GameplayNodes").visible=true
	GameManager.isGamePlaying=true
	GameManager.hasStartSeqFinished=true
