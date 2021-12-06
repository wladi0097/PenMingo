extends "res://entities/enemies/EnemyBase.gd"

enum ENEMY_TYPE {regular, shotgun}
export(ENEMY_TYPE) var currentType = ENEMY_TYPE.regular

var speed = 30
var speedWhileShooting = 15
var shotgunSpread =  0.3
onready var checkPlayerVisible := $checkPlayerVisible
onready var shotCooldown := $shotCooldown
onready var shotPosition := $shotPosition
onready var shootAudio := $shootAudio

func _ready():
	if currentType == ENEMY_TYPE.regular:
		$movementSprite/regularMoveSprite.show()
		$attackSprite/regularAttackSprite.show()
	else:
		$movementSprite/shotgunMoveSprite.show()
		$attackSprite/shotgunAttackSprite.show()

func regularShoot():
	shootAudio.play()
	spawnBullet(shotPosition.global_position, rotation)
	
func shotgunShoot():
	shootAudio.play()
	spawnBullet(shotPosition.global_position, rotation)
	spawnBullet(shotPosition.global_position, rotation + shotgunSpread)
	spawnBullet(shotPosition.global_position, rotation - shotgunSpread)
	
func shoot():
	if shotCooldown.is_stopped():
		shotCooldown.start()
		if currentType == ENEMY_TYPE.regular:
			regularShoot()
		elif currentType == ENEMY_TYPE.shotgun:
			shotgunShoot()

func _physics_process(delta):
	if checkPlayerVisible.get_collider() is KinematicBody2D:
		showAttack()
		shoot()
		move_and_slide(getPathToPlayer() * speedWhileShooting)
	else:
		showMovement()
		move_and_slide(getPathToPlayer() * speed)

