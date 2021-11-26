extends Node2D
class_name FightStage

export(bool) var noFightRoom = false
var roomcleared = false
export var waves = 1
var aliveEnemies = 0
onready var spawnPositions := $Navigation2D/SpawnPositions
onready var enemySpawner := preload("res://entities/Spawner.tscn")
onready var pickupItem := preload("res://entities/Pickup.tscn")
onready var fightText := $CanvasLayer/FightText
onready var animations := $AnimationPlayer
onready var finishAudio := $finishAudio
onready var exitBlocker := $Navigation2D/Exit/ExitBlocker
onready var rewardPosition := $Navigation2D/Reward/RewardPosition

var rng = RandomNumberGenerator.new()

var startFightTexts = ["Fight!", "Go Go Go", "Start Fight", "READY ? FIGHT!", "Doors closed"]
var endFightTexts = ["Good Job", "Too easy", "Fight finished", "<- Continue ->", "Doors open"]

func _ready():
	if noFightRoom:
		allowToExit()
		spawnReward()
	else:
		startOfFight()


func startOfFight():
	showFightText(startFightTexts[rng.randi_range(0, startFightTexts.size() -1)])
	spawnEnemies()

func spawnEnemies():
	for point in spawnPositions.get_children():
		var instance = enemySpawner.instance()
		instance.chooseRandomEnemy()
		instance.spawnNode = spawnPositions
		instance.global_position = point.global_position
		spawnPositions.add_child(instance)
		
		aliveEnemies += 1

func endOfFight():
	spawnReward()
	allowToExit()
	finishAudio.play()
	showFightText(endFightTexts[rng.randi_range(0, endFightTexts.size() -1)])

func spawnReward():
	var instance = pickupItem.instance()
	
	instance.chooseRandom()
	instance.global_position = rewardPosition.global_position
	add_child(instance)
	
func allowToExit():
	roomcleared = true
	exitBlocker.hide()

# will be called from the child enemy
func enemyDied():
	aliveEnemies -= 1
	
	if aliveEnemies == 0:
		waves -= 1
		if waves == 0:
			endOfFight()
		else:
			spawnEnemies()
			
func showFightText(content):
	fightText.text = content
	animations.play("showFightText")

func _on_Exit_body_entered(body):
	if roomcleared:
		CURRENT_RUN.switchToNextRoom()
