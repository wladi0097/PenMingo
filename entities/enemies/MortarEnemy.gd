extends "res://entities/enemies/EnemyBase.gd"

onready var shootAnimation := $ShootAnimation

func _ready():
	showAttack()

func mortarShoot():
	spawnBomb()

func _on_ShootTimer_timeout():
	shootAnimation.play("attack")
