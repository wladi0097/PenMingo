extends Node2D

onready var animations := $AnimationPlayer
onready var navigationNode : Navigation2D = find_parent("Navigation2D")

var rng = RandomNumberGenerator.new()
var spawnNode

var enemies = []
enum ENEMIES {regularShooter,regularDrone, mortarEnemy, shotgunShooter, assaultShooter, shieldEnemy}
export(ENEMIES) var spawnEnemy = ENEMIES.regularShooter

var easyMode = [50, 20, 10, 5, 5, 10]
var normalMode = [20, 20, 20, 15, 15, 10]
var hardMode = [5, 10, 25, 25, 25, 10]

func getModeByClearedRooms():
	if CURRENT_RUN.thisRunClearedRooms <= 2: return easyMode
	elif CURRENT_RUN.thisRunClearedRooms <= 4: return normalMode
	else: return hardMode

func getEnemyByPercentage():
	rng.randomize()
	
	var mode = getModeByClearedRooms()
	var e = rng.randi_range(0, 100)
	
	if e <= mode[0]: return ENEMIES.regularShooter
	elif e <= mode[0] + mode[1]: return ENEMIES.regularDrone
	elif e <= mode[0] + mode[1] + mode[2]: return ENEMIES.mortarEnemy
	elif e <= mode[0] + mode[1] + mode[2] + mode[3]: return ENEMIES.shotgunShooter
	elif e <= mode[0] + mode[1] + mode[2] + mode[3] + mode[4]: return ENEMIES.assaultShooter
	else: return ENEMIES.shieldEnemy

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
		ENEMIES.shieldEnemy:
			instance= load("res://entities/enemies/ShieldEnemy.tscn").instance()
			
			
	instance.global_position = global_position
	
	if spawnNode == null:
		navigationNode.add_child(instance)
	else:
		spawnNode.add_child(instance)
			
	animations.play("spawnComplete")
	yield(animations, "animation_finished")
	queue_free()
