extends Node

onready var upgradeSelectionScreen = $ChooseUpgrade
onready var upgradeAudio = $UpgradeAudio
var rng = RandomNumberGenerator.new()

enum STATUPGRADES {
	 PENGUIN_FASTER_BULLETS, PENGUIN_FASTER_SHOOT, PENGUIN_MORE_DAMAGE, PENGUIN_MORE_RANGE, FLAMINGO_MORE_DAMAGE,
	 FLAMINGO_FASTER_SHOOT, MOVEMENT_SPEED
	}
var statusUpgradeText = ["Penguin faster bullets", "Penguin faster shot", "Penguin more damage", "penguin more range", "flamingo more damage", "flamingo faster shot", "faster movement speed"]

enum UPGRADES {TRIPPLE_SHOT, EXPLOSIVE_SHOT, FLAMINGO_BACK_SHOOT, FLAMINGO_BULLET_FOLLOWS_MOUSE, DASH_DAMAGE,  DEFENSE_SURROUNDING, CRIT_DMG, PENGUIN_BOUNCY_BULLET}
var upgradeText = ["Penguin tripple shot", "Flamingo explosive shot", "Penguin got your back!", "Flamingo mind control", "Fire Dash", "Little defense Friend", "This game has crit damage ? (3% btw)", "Penguin bouncy bullets", "No more upgrades :-("]

enum REWARDS {HEALTH, UPGRADE, MAX_HEALTH, STAT_UPGRADE}

var allRooms = ["res://worlds/stage01_zoo/Room01.tscn", "res://worlds/stage01_zoo/Room02.tscn", "res://worlds/stage01_zoo/Room03.tscn", "res://worlds/stage01_zoo/Room04.tscn", "res://worlds/stage01_zoo/Room05.tscn", "res://worlds/stage01_zoo/Room06.tscn"]
var bossRoom = "res://worlds/stage01_zoo/Room01.tscn"
var entryRoom := "res://worlds/stage01_zoo/Entry.tscn"

var roomSelection = []
var upgradeSelection = []
var rewardSelection = []

var roomsThisrun = []
var currentUpgrades = []

var currentMap
var currentRoomReward = null # Set by loadNextRoomWithReward and handled by MapPoint
var neededRewardsCount = 13 # Amount of points in map

# Player stats: SET BY resetStatValues
var currentMaxHp
var currentHp 
var currentPenguinShootSpeed
var currentFlamingoShootSpeed
var currentMovementSpeed
var currentPenguinBulletSpeed
var currentPenguinDamage
var currentPenguinRange
var currentFlamingoDamage
var currentFlamingoBulletSpeed

# Stats about the run:
var thisRunDealthDamage = 0
var thisRunKilledEnemies = 0
var thisRunTimerStarted = 0
var thisRunSwitchedPlayers = 0

func _ready():
	randomize()
	resetStatValues()
	resetRunStats()
	rng.randomize()

func resetRunStats():
	thisRunDealthDamage = 0
	thisRunKilledEnemies = 0
	thisRunTimerStarted = 0
	thisRunSwitchedPlayers = 0

func resetStatValues():
	currentMaxHp = 5
	currentHp = 4
	currentPenguinShootSpeed = 0.45
	currentFlamingoShootSpeed = 1
	currentMovementSpeed = 150
	currentFlamingoDamage = 4
	currentFlamingoBulletSpeed = 400
	currentPenguinBulletSpeed = 120
	currentPenguinDamage = 1
	currentPenguinRange = 2
	
func getTextForUpgrade(upgradeName):
	return upgradeText[upgradeName]

func hasUpgrade(upgradeName):
	return currentUpgrades.has(upgradeName)

func showUpgradeSelectionScreen():
	upgradeSelectionScreen.showRewardSelection()

func getTwoRandomUpgrades():
	$UpgradeAudio.play()
	if upgradeSelection.size() == 0:
		return [-1, -1]
	elif upgradeSelection.size() == 1:
		return [upgradeSelection[0], -1]
	else:
		return [upgradeSelection[0], upgradeSelection[1]]

func getTextForStatusUpgrade(upgradeName):
	return statusUpgradeText[upgradeName]
	
func applyRandomStatusUpgrade():
	$UpgradeAudio.play()
	var statusUpgrade = rng.randi_range(0, STATUPGRADES.size() - 1)
	
	match statusUpgrade:
		STATUPGRADES.PENGUIN_FASTER_BULLETS:
			currentPenguinBulletSpeed += 30
		STATUPGRADES.PENGUIN_FASTER_SHOOT:
			currentPenguinShootSpeed *= 0.9
		STATUPGRADES.PENGUIN_MORE_DAMAGE:
			currentPenguinDamage += 0.5
		STATUPGRADES.PENGUIN_MORE_RANGE:
			currentPenguinRange += 1
		STATUPGRADES.FLAMINGO_MORE_DAMAGE:
			currentFlamingoDamage *= 1.2
		STATUPGRADES.FLAMINGO_FASTER_SHOOT:
			currentFlamingoShootSpeed *= 0.8
		STATUPGRADES.MOVEMENT_SPEED:
			currentMovementSpeed += 15
	
	return statusUpgrade
	
func upgradeSelected(upgrade):
	upgradeSelection.remove(upgradeSelection.find(upgrade))
	currentUpgrades.push_back(upgrade)
	
func getRandomReward():
	if rewardSelection.size() == 0:
		return REWARDS.HEALTH # fallback if rewards were not enough
	
	var reward = rewardSelection[0]
	rewardSelection.remove(0)
	return reward
	
func loadNextRoomWithReward(reward = REWARDS.HEALTH):
	if roomsThisrun.size() <= 0:
		buildRoomSelection()
	
	currentRoomReward = reward
	
	LOADING_TRANSITION.start()
	yield(LOADING_TRANSITION, "animation_finished")
	
	currentMap.disable()
	get_tree().change_scene(roomsThisrun[0])
	roomsThisrun.remove(0)
	
func loadSpecificRoomWithReward(roomToLoad, reward = REWARDS.HEALTH):
	currentRoomReward = reward
	
	LOADING_TRANSITION.start()
	yield(LOADING_TRANSITION, "animation_finished")
	currentMap.disable()
	get_tree().change_scene_to(roomToLoad)
	
func loadEntryRoom():
	currentMap.disable()
	get_tree().change_scene(entryRoom)

func startNewRun():
	resetStatValues()
	resetRunStats()
	buildUpgradeSelection()
	buildRoomSelection()
	buildRewardSelection()
	
	addMap()
	loadEntryRoom()
	thisRunTimerStarted = OS.get_system_time_secs()
	GLOBAL.allRunsAttemts += 1
	
func buildRoomSelection():
	roomsThisrun = allRooms.duplicate(true)
	roomsThisrun.shuffle()
	
func buildUpgradeSelection():
	currentUpgrades = []
	upgradeSelection = range(UPGRADES.size())
	upgradeSelection.shuffle()
	
func buildRewardSelection():
	var newRewardSelection = []
	var rewardsLeft = neededRewardsCount
	
	var maxHealthContainer = rng.randi_range(2, 3)
	rewardsLeft -= maxHealthContainer
	for i in range(maxHealthContainer):
		newRewardSelection.push_back(REWARDS.MAX_HEALTH)
	
	var upgrades = floor(rewardsLeft / 3)
	rewardsLeft -= upgrades
	for i in range(upgrades):
		newRewardSelection.push_back(REWARDS.UPGRADE)
	
	var statUpgrades = floor(rewardsLeft / 2)
	rewardsLeft -= statUpgrades
	for i in range(statUpgrades):
		newRewardSelection.push_back(REWARDS.STAT_UPGRADE)
	
	for i in range(rewardsLeft):
		newRewardSelection.push_back(REWARDS.HEALTH)
	
	newRewardSelection.shuffle()
	
	# first reward should never be health
	if newRewardSelection[0] == REWARDS.HEALTH:
		newRewardSelection[0] = REWARDS.STAT_UPGRADE
	
	rewardSelection = newRewardSelection
	
func addMap():
	if has_node("Map"):
		get_node("Map").queue_free()
	
	var instance = load("res://worlds/Map.tscn").instance()
	add_child(instance)
	currentMap = instance

func PlayerClickedRestart():
	currentMap.disable()
	get_tree().change_scene("res://worlds/Lobby.tscn")

func switchToMap():
	currentMap.enable()
	
	LOADING_TRANSITION.end()
	yield(LOADING_TRANSITION, "animation_finished")
