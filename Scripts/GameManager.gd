extends Node

const CHARACTER_SPEEDS = [250.0,200.0,300.0,300.0]
const CHARACTER_JUMP_VELS = [-500.0,-450.0,-600.0,-600.0]
const CHARACTER_ATTACK_PWRS = [7.0,14.0,5.0,5.0]
const CHARACTER_DASH_ATTACK_PWRS = [12.0,16.0,9.0,9.0]
const START_TIMES={
	"CrabRave":2.55,
	"Chromatically":2.15,
	"DeadManWalking":2.55,
	"GhostsNStuff":2.55,
	"ItsYou":2.55
}

var currentNote=0
var isGamePlaying=false
var hasStartSeqFinished=false
var platformsList=[]
var platformPrevList=[]
var spikeList=[]
var spikePrevList=[]
var arePlayersAlive=[]
var playerAttackStatus=[]
var currentPlayerKeybinds=[]
var playerSpriteSheets=[]
var playerSpriteIcons=[]
var currentCharacterSpeeds=[]
var currentCharacterJumpVels=[]
var currentCharacterAttackPwr=[]
var currentCharacterDashAttackPwr=[]
var mapName=""
var playerLoadCount=0
var player_count := 0
var next_player_id := 0
var isSongOver=false
var currentPowerupIndex = -1
var currentPowerupType = -1
var rng = RandomNumberGenerator.new()
var levelBPM = 0

func setCharacterAttribute(charIndex, att):
	match att:
		0:
			currentCharacterSpeeds.append(CHARACTER_SPEEDS[charIndex])
		1:
			currentCharacterJumpVels.append(CHARACTER_JUMP_VELS[charIndex])
		2:
			currentCharacterAttackPwr.append(CHARACTER_ATTACK_PWRS[charIndex])
		3:
			currentCharacterDashAttackPwr.append(CHARACTER_DASH_ATTACK_PWRS[charIndex])

func choose_new_powerup():
	currentPowerupIndex = rng.randi_range(1, 3)
	currentPowerupType = rng.randi_range(1, 3)
	print("i choose ",currentPowerupIndex)

#rejestracja gracza do tabeli
func register_player() -> int:
	arePlayersAlive.push_back(true)
	playerAttackStatus.push_back(false)
	player_count += 1
	next_player_id += 1
	return next_player_id

#wyszukiwanie platform
func searchForPlatforms():
	if mapName!="":
		
		#normalne
		for i in range(1,6):
			var platformNode = get_parent().get_node(str(mapName)).get_node(str("Platforms")+str(i))
			#print(platformNode)
			platformsList.push_back(platformNode)
			
		#ostrzegawcze
		for i in range(1,6):
			var platformPrevNode = get_parent().get_node(str(mapName)).get_node(str("Platforms")+str(i)+str("Prev"))
			#print(platformPrevNode)
			platformPrevList.push_back(platformPrevNode)
	
func searchForSpikes():
	if mapName!="":
		
		#normalne
		for i in range(1,3):
			var spikeNode = get_parent().get_node(str(mapName)).get_node(str("Spikes")+str(i))
			#print(spikeNode)
			spikeList.push_back(spikeNode)
		
		#ostrzegawcze
		for i in range(1,3):
			var spikePrevNode = get_parent().get_node(str(mapName)).get_node(str("Spike")+str(i)+str("PrevGroup"))
			#print(spikePrevNode)
			spikePrevList.push_back(spikePrevNode)
		
