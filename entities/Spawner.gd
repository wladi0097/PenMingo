extends Node2D

onready var animations := $AnimationPlayer
onready var navigationNode : Navigation2D = find_parent("Navigation2D")

var rng = RandomNumberGenerator.new()
var spawnNode

var enemies = []
# <easy  ---  hard>
enum ENEMIES {regularShooter, regularDrone, mortarEnemy, shotgunShooter, assaultShooter}
export(ENEMIES) var spawnEnemy = ENEMIES.regularShooter

var easyMode = [60, 20, 10, 5, 5]
var normalMode = [20, 20, 20, 20, 20]
var hardMode = [5, 10, 30, 25, 30]

func getModeByClearedRooms():
	if CURRENT_RUN.thisRunClearedRooms <= 2: return easyMode
	elif CURRENT_RUN.thisRunClearedRooms <= 4: return normalMode
	else: return hardMode

func getEnemyByPercentage():
	rng.randomize()
	
	var mode = getModeByClearedRooms()
	var e = rng.randi_range(0, 100)
	
	prints("mode",mode, "rand", e)
	
	if e <= mode[0]: return ENEMIES.regularShooter
	elif e <= mode[0] + mode[1]: return ENEMIES.regularDrone
	elif e <= mode[0] + mode[1] + mode[2]: return ENEMIES.mortarEnemy
	elif e <= mode[0] + mode[1] + mode[2] + mode[3]: return ENEMIES.shotgunShooter
	else: return ENEMIES.assaultShooter

func chooseRandomEnemy():
	spawnEnemy = getEnemyByPercentage()

func _ready():
	yield(get_tree().create_timer(rng.randf_range(0, 3)), "timeout")
	
	animations.play("spawn")
	yield(animations, "animation_finished")
	
	var instance: KinematicBody2D
	match spawnEnemy:
		ENEMIES.regularShooter:
			instance = load("res://entities/enemies/ShootEnemy.tscn").instance()
		ENEMIES.shotgunShooter:
			instance = load("res://entities/enemies/ShootEnemy.tscn").instance()
			instance.currentType = 1
		ENEMIES.assaultShooter:
			instance = load("res://entities/enemies/ShootEnemy.tscn").instance()
			instance.currentType = 2
		ENEMIES.mortarEnemy:
			instance= load("res://entities/enemies/MortarEnemy.tscn").instance()
		ENEMIES.regularDrone:
			instance= load("res://entities/enemies/RunnerEnemy.tscn").instance()
			
			
	instance.global_position = global_position
	
	if spawnNode == null:
		navigationNode.add_child(instance)
	else:
		spawnNode.add_child(instance)
			
	animations.play("spawnComplete")
	yield(animations, "animation_finished")
	queue_free()
