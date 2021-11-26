extends Node


var rng = RandomNumberGenerator.new()

enum UPGRADES {TRIPPLE_SHOT, EXPLOSIVE_SHOT}
var upgradeText = ["Penguin tripple shot", "Flamingo explosive shot", "No more upgrades :-("]

var allRooms = ["res://worlds/stage01_zoo/Room01.tscn", "res://worlds/stage01_zoo/Room02.tscn", "res://worlds/stage01_zoo/Room03.tscn"]
var bossRoom = "res://worlds/stage01_zoo/Room01.tscn"
var entryRoom := "res://worlds/stage01_zoo/Entry.tscn"

var roomCountInRun = 3
var roomSelection = []
var upgradeSelection = []

var roomsThisrun = []
var currentRoom = 0
var currentUpgrades = []


func _ready():
	rng.randomize()

func getTextForUpgrade(upgradeName):
	return upgradeText[upgradeName]

func hasUpgrade(upgradeName):
	return currentUpgrades.has(upgradeName)

func getRandomUpgrade():
	if upgradeSelection.size() == 0:
		return -1
	
	var upgradeIndex = rng.randi_range(0, upgradeSelection.size() -1)	
	var upgrade = upgradeSelection[upgradeIndex]
	currentUpgrades.push_back(upgrade)
	upgradeSelection.remove(upgradeIndex)
	return upgrade

func startNewRun():
	print("start new run")
	
	roomsThisrun = [entryRoom]
	
	roomSelection = allRooms.duplicate(true)
	upgradeSelection = range(UPGRADES.size())
	
	for i in range(roomCountInRun):
		var roomIndex = rng.randi_range(0, roomSelection.size() -1)
		roomsThisrun.push_back(roomSelection[roomIndex])
		roomSelection.remove(roomIndex)
	
	roomsThisrun.push_back(bossRoom)
	switchToNextRoom()

func switchToNextRoom():
	get_tree().change_scene(roomsThisrun[0])
	roomsThisrun.remove(0)
