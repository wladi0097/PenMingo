extends Node

var rng = RandomNumberGenerator.new()

enum UPGRADES {TRIPPLE_SHOT, EXPLOSIVE_SHOT}
var upgradeText = ["Penguin tripple shot", "Flamingo explosive shot", "No more upgrades :-("]

enum REWARDS {HEALTH, UPGRADE}

var allRooms = ["res://worlds/stage01_zoo/Room01.tscn", "res://worlds/stage01_zoo/Room02.tscn"]
var bossRoom = "res://worlds/stage01_zoo/Room01.tscn"
var entryRoom := "res://worlds/stage01_zoo/Entry.tscn"

var roomSelection = []
var upgradeSelection = []
var rewardSelection = []

var roomsThisrun = []
var currentRoom = 0
var currentUpgrades = []

var currentMap
var currentRoomReward = null # Set by loadNextRoomWithReward and handled by MapPoint
var neededRewardsCount = 13 # Amount of points in map

func _ready():
	randomize()
	rng.randomize()
	
func getTextForUpgrade(upgradeName):
	return upgradeText[upgradeName]

func hasUpgrade(upgradeName):
	return currentUpgrades.has(upgradeName)

func getRandomUpgrade():
	if upgradeSelection.size() == 0:
		return -1
	
	var upgrade = upgradeSelection[0]
	currentUpgrades.push_back(upgrade)
	upgradeSelection.remove(0)
	return upgrade
	
func getRandomReward():
	if rewardSelection.size() == 0:
		return REWARDS.HEALTH # fallback if rewards were not enough
		
	var reward = rewardSelection[0]
	rewardSelection.remove(0)
	return reward
	
func loadNextRoomWithReward(reward = REWARDS.HEALTH):
	if roomsThisrun.size() == 0:
		buildRoomSelection()
	
	currentRoomReward = reward
	currentMap.disable()
	get_tree().change_scene(roomsThisrun[0])
	roomsThisrun.remove(0)
	
func loadEntryRoom():
	currentMap.disable()
	get_tree().change_scene(entryRoom)

func startNewRun():
	buildUpgradeSelection()
	buildRoomSelection()
	buildRewardSelection()
	
	addMap()
	loadEntryRoom()
	
func buildRoomSelection():
	roomsThisrun = allRooms.duplicate(true)
	roomsThisrun.shuffle()
	
func buildUpgradeSelection():
	upgradeSelection = range(UPGRADES.size())
	upgradeSelection.shuffle()
	
func buildRewardSelection():
	var newRewardSelection = []
	var rewardsLeft = neededRewardsCount
	
	var upgrades = floor(rewardsLeft / 3)
	rewardsLeft -= upgrades
	for i in range(upgrades):
		newRewardSelection.push_back(REWARDS.UPGRADE)
	
	var health = rewardsLeft
	for i in range(health):
		newRewardSelection.push_back(REWARDS.HEALTH)
	
	newRewardSelection.shuffle()
	rewardSelection = newRewardSelection
	print(rewardSelection)
	
func addMap():
	if has_node("Map"):
		get_node("Map").queue_free()
	
	var instance = load("res://worlds/Map.tscn").instance()
#	call_deferred("add_child", instance)
	add_child(instance)
	currentMap = instance

func PlayerClickedRestart():
	currentMap.disable()
	get_tree().change_scene("res://worlds/Lobby.tscn")

func switchToMap():
	currentMap.enable()
