extends Node2D
class_name FightStage

export(int) var minAmountOfEnemies = 6
export(int) var maxAmountOfEnemies = 12
export(int) var maximumEnemiesAtOnce = 5
export(bool) var noFightRoom = false
export var isBossFightRoom = false

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

var aliveEnemies = 0
var enemiesToKillBeforeClear = 0
var roomcleared = false

func _ready():
	rng.randomize()
	playRandomSongOrPreSelected()
	LOADING_TRANSITION.end()
	yield(LOADING_TRANSITION, "animation_finished")

	enemiesToKillBeforeClear = rng.randi_range(minAmountOfEnemies, maxAmountOfEnemies)
	if noFightRoom:
		allowToExit()
		spawnReward()
	elif isBossFightRoom:
		aliveEnemies = 1
		$SpawnEnemiesPeriodicallyForBossFights.start()
	else:
		startOfFight()

func playRandomSongOrPreSelected():
	var songToPlay: AudioStreamPlayer
	
	if $OverrideRandomSong.get_child_count() > 0:
		songToPlay = $OverrideRandomSong.get_child(0)
	else:
		songToPlay = $Songs.get_child(rng.randi_range(0, $Songs.get_child_count() - 1))
	
	songToPlay.play()

func startOfFight():
	showFightText(startFightTexts[rng.randi_range(0, startFightTexts.size() -1)])
	spawnIntialEnemies()

func spawnIntialEnemies():
	# maximumEnemiesAtOnce
	var points = getAllEnemySpawnPoints()
	if (points.size() < maximumEnemiesAtOnce):
		maximumEnemiesAtOnce = points.size()
	for point in points.slice(0, maximumEnemiesAtOnce - 1):
		addRandomEnemyInstanceToScene(point.global_position)
		
func spawnEnemyAtRandomPosition():
	addRandomEnemyInstanceToScene(getAllEnemySpawnPoints()[0].global_position)

func getAllEnemySpawnPoints() -> Array:
	var spawnPointsInScene = []
	for point in spawnPositions.get_children():
		if (point is Position2D):
			spawnPointsInScene.append(point)
	spawnPointsInScene.shuffle()
	return spawnPointsInScene

func addRandomEnemyInstanceToScene(spawnPosition):
	var instance = enemySpawner.instance()
	instance.chooseRandomEnemy()
	instance.spawnNode = spawnPositions
	instance.global_position = spawnPosition
	spawnPositions.add_child(instance)
	aliveEnemies += 1
	enemiesToKillBeforeClear -= 1

func endOfFight():
	spawnReward()
	allowToExit()
	finishAudio.play()
	showFightText(endFightTexts[rng.randi_range(0, endFightTexts.size() -1)])

func spawnReward():
	var instance = pickupItem.instance()
	
	instance.global_position = rewardPosition.global_position
	add_child(instance)
	
func allowToExit():
	roomcleared = true
	exitBlocker.hide()

# will be called from the child enemy
func enemyDied(entity):
	aliveEnemies -= 1
	
	if !isBossFightRoom && enemiesToKillBeforeClear > 0:
		spawnEnemyAtRandomPosition()
	
	if aliveEnemies == 0:
		endOfFight()
		
			
func showFightText(content):
	fightText.text = content
	animations.play("showFightText")

func _on_Exit_body_entered(body):
	if roomcleared:
		LOADING_TRANSITION.start()
		yield(LOADING_TRANSITION, "animation_finished")
		
		CURRENT_RUN.switchToMap()
		queue_free()

func _on_SpawnEnemiesPeriodicallyForBossFights_timeout():
	if !roomcleared:
		spawnEnemyAtRandomPosition()
