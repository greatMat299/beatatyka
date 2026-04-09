extends Control

var startTime : float = 0.0
var startTime2 : float = 0.0
var noteSpeed : float
@export var BeatRectScene : PackedScene
@export var beatAttackValue : float = 0.5
var mapName=""
var beatSum=0
var attackers := []
var players = []
var attackWindowOpen := false
var isInArea=false
var isStarted=false
var beatMultiplier=0
var comboAttacks=0
var potentialAttackCombo=0

signal beatAttacked(playerIndex,beatType,comboAmount)

func _process(delta):
	if GameManager.hasStartSeqFinished==true and isStarted==false:
		isStarted=true
		noteSpeed=get_parent().get_parent().noteSpeed
		startCatcher()
	#print(comboAttacks)
		
func startCatcher():
	#dodanie graczy
	await get_tree().process_frame
	for p in get_tree().get_nodes_in_group("player"):
		players.push_back(p)
		p.playerAttack.connect(self.onPlayerAttack)
	print(players)
	
	#dodanie MIDI playerów
	await get_tree().process_frame
	var midiPlayer = get_tree().get_nodes_in_group("midiPlayer")[3]
	var midiPlayer2 = get_tree().get_nodes_in_group("midiPlayer")[5]
	var mapName = get_parent().get_parent().get_parent().name
	startTime=GameManager.START_TIMES[mapName]
	startTime2=GameManager.START_TIMES_2[mapName]
	midiPlayer2.current_time=startTime2
	midiPlayer.current_time=startTime
	midiPlayer.note_played_wc.connect(self._on_note_played)
	midiPlayer2.note_played_wc.connect(self._on_note_played)
	
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
	elif note>=68&&note<=69: #bomba
		copy.get_node("BeatRectCube").color = Color(0.0, 0.0, 0.0, 1.0)
	elif note>=70&&note<=73: #laser
		copy.get_node("BeatRectCube").color = Color(0.214, 0.48, 1.0, 1.0)
	elif note==74: #zmiana platformy
		copy.get_node("BeatRectCube").color = Color(0.81, 0.685, 0.0, 1.0)
	else:
		copy.get_node("BeatRectCube").color = Color(1.0, 1.0, 1.0, 1.0)
	if note>=59:
		add_child(copy)

#akcje po ataku gracza
func onPlayerAttack(player, damage, playerDamaged, direction):
	if not isInArea:
		comboAttacks=0
		potentialAttackCombo=0
		beatAttacked.emit(player,0,0)
		return
		
	if playerDamaged.player_id != player:
		if playerDamaged not in attackers:
			attackers.append(playerDamaged)
	
	if not attackWindowOpen:
		attackWindowOpen=true
		await get_tree().create_timer(0.1).timeout
		comboAttacks+=1
		beatAttacked.emit(player,beatMultiplier,comboAttacks)
		processAttackWindow()
		
	print(attackers)
		
#zadanie odpowiedniej ilości dodatkowego ataku dla ataków z beatem
func processAttackWindow():
	print(attackers)
	if attackers.size() >= 2:
		print("players attacked")
		for player in attackers:
			player.get_node("HealthManager").health -= beatAttackValue*beatMultiplier+comboAttacks/10.0
			
	else:
		for player in attackers:
			player.get_node("HealthManager").health -= beatAttackValue*beatMultiplier+comboAttacks/10.0
			

	attackers.clear()
	attackWindowOpen = false

#akcje po wejściu nuty w strefę beatu
func _on_beat_area_entered(area, extra_arg_0):
	if isInArea==false:
		potentialAttackCombo+=1
		isInArea=true
	beatMultiplier=extra_arg_0


#akcje po wyjściu nuty w strefę beatu
func _on_beat_area_exited(area, extra_arg_0):
	beatMultiplier=extra_arg_0
	if extra_arg_0==0:
		isInArea=false
		if comboAttacks<potentialAttackCombo:
			comboAttacks=0
			potentialAttackCombo=0
