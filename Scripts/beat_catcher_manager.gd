extends Control

@export var startTime : float = 5.0
@export var noteSpeed : float = 200.0
@export var BeatRectScene : PackedScene
@export var beatAttackValue : float = 0.5
var mapName=""
var beatSum=0
var attackers := []
var players = []
var attackWindowOpen := false
var isInArea=false
var beatMultiplier=0

func _ready():
	#dodanie graczy
	await get_tree().process_frame
	for p in get_tree().get_nodes_in_group("player"):
		players.push_back(p)
		p.playerAttack.connect(self.onPlayerAttack)
	print(players)
	
	#dodanie MIDI playerów
	await get_tree().process_frame
	var midiPlayer = get_tree().get_nodes_in_group("midiPlayer")[3]
	midiPlayer.current_time=startTime
	midiPlayer.note_played_wc.connect(self._on_note_played)
	
#zainicjonowanie obiektu nuty
func _on_note_played(note, sender):
	var copy = BeatRectScene.instantiate()
	copy.position.x = 0
	copy.isNotePlaying = true
	copy.noteSpeed=noteSpeed
	if note>=59&&note<=64: #platforma
		copy.get_node("BeatRectCube").color = Color(0.607, 0.01, 0.536, 1.0)
	elif note>=65&&note<=67: #kolce
		copy.get_node("BeatRectCube").color = Color(0.967, 0.0, 0.083, 1.0)
	else:
		copy.get_node("BeatRectCube").color = Color(1.0, 1.0, 1.0, 1.0)
	add_child(copy)

#akcje po ataku gracza
func onPlayerAttack(player, damage, playerDamaged, direction):
	if not isInArea:
		return
		
	if playerDamaged not in attackers:
		attackers.append(playerDamaged)
	
	if not attackWindowOpen:
		attackWindowOpen=true
		await get_tree().create_timer(0.1).timeout
		processAttackWindow()
		
	print(attackers)
		
#zadanie odpowiedniej ilości dodatkowego ataku dla ataków z beatem
func processAttackWindow():
	if attackers.size() >= 2:
		print("players attacked")
		for player in attackers:
			player.get_node("HealthManager").health -= beatAttackValue*beatMultiplier
	else:
		for player in attackers:
			player.get_node("HealthManager").health -= beatAttackValue*beatMultiplier

	attackers.clear()
	attackWindowOpen = false

#akcje po wejściu nuty w strefę beatu
func _on_beat_area_entered(area, extra_arg_0):
	isInArea=true
	beatMultiplier=extra_arg_0


#akcje po wyjściu nuty w strefę beatu
func _on_beat_area_exited(area, extra_arg_0):
	isInArea=false
	beatMultiplier=extra_arg_0
