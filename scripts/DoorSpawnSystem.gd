extends Node2D

var wasUsed = false
export var waves = 2
export(bool) var enabled = true
onready var wallContainer := $ClosedUp
onready var spawnPositions := $SpawnPositions
onready var enemySpawner := preload("res://entities/Spawner.tscn")
onready var closeUpSprite := $CloseUpSprite
onready var fightText := $CanvasLayer/FightText
onready var animations := $AnimationPlayer
onready var finishAudio := $finishAudio
var rng = RandomNumberGenerator.new()

var startFightTexts = ["Fight!", "Go Go Go", "Start Fight", "READY ? FIGHT!", "Doors closed"]
var endFightTexts = ["Good Job", "Too easy", "Fight finished", "<- Continue ->", "Doors open"]

var aliveEnemies = 0

func _ready():
	rng.randomize()

func _on_EntryDoor_body_entered(body):
	if !wasUsed && enabled:
		wasUsed = true
		startOfFight()
		
func closeUp():
	wallContainer.set_collision_layer_bit(0, true)
	for walls in wallContainer.get_children():
		var w: CollisionShape2D = walls
		var sprite = closeUpSprite.duplicate()
		
		var spriteSize = 64
		
		sprite.global_transform = w.global_transform
		sprite.scale.x = (spriteSize * w.shape.extents.x / 2000) * sprite.scale.x
		sprite.scale.y = (spriteSize * w.shape.extents.y / 2000) * sprite.scale.y
		print(spriteSize, w.shape.extents.x)
		sprite.visible = true
		
		wallContainer.add_child(sprite)
	
func spawnEnemies():
	for point in spawnPositions.get_children():
		var instance = enemySpawner.instance()
		instance.chooseRandomEnemy()
		instance.spawnNode = self
		instance.global_position = point.global_position
		add_child(instance)
		
		aliveEnemies += 1

func startOfFight():
	showFightText(startFightTexts[rng.randi_range(0, startFightTexts.size() -1)])
	closeUp()
	spawnEnemies()
	
func endOfFight():
	finishAudio.play()
	showFightText(endFightTexts[rng.randi_range(0, endFightTexts.size() -1)])
	yield(animations, "animation_finished")
	queue_free()

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
