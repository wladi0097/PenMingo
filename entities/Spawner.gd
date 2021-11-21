extends Node2D

onready var animations := $AnimationPlayer
onready var navigationNode : Navigation2D = find_parent("Navigation2D")

var enemies = []
enum ENEMIES {regularShooter, shotgunShooter, regularDrone}
export(ENEMIES) var spawnEnemy = ENEMIES.regularShooter

func _ready():
	animations.play("spawn")
	yield(animations, "animation_finished")
	
	var instance: KinematicBody2D
	match spawnEnemy:
		ENEMIES.regularShooter:
			instance = load("res://entities/ShootEnemy.tscn").instance()
		ENEMIES.shotgunShooter:
			instance = load("res://entities/ShootEnemy.tscn").instance()
			instance.currentType = 1
		ENEMIES.regularDrone:
			instance= load("res://entities/RunnerEnemy.tscn").instance()
			
	instance.global_position = global_position
	navigationNode.add_child(instance)
			
	animations.play("spawnComplete")
	yield(animations, "animation_finished")
	queue_free()
