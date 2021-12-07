extends Node2D

onready var animations := $AnimationPlayer
onready var navigationNode : Navigation2D = find_parent("Navigation2D")

var rng = RandomNumberGenerator.new()
var spawnNode

var enemies = []
enum ENEMIES {regularShooter, shotgunShooter, assaultShooter, mortarEnemy, regularDrone}
export(ENEMIES) var spawnEnemy = ENEMIES.regularShooter

func chooseRandomEnemy():
	rng.randomize()
	spawnEnemy = rng.randi_range(0, ENEMIES.size() - 1)

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
