extends "res://entities/enemies/EnemyBase.gd"

enum ENEMY_TYPE {regular, shotgun, assault}
export(ENEMY_TYPE) var currentType = ENEMY_TYPE.regular

var speed = 30
var speedWhileShooting = 15
var shotgunSpread =  0.3
onready var checkPlayerVisible := $checkPlayerVisible
onready var shotCooldown := $shotCooldown
onready var shotPosition := $shotPosition
onready var shootAudio := $shootAudio

func _ready():
	match currentType:
		ENEMY_TYPE.regular:
			$movementSprite/regularMoveSprite.show()
			$attackSprite/regularAttackSprite.show()
		ENEMY_TYPE.shotgun:
			$movementSprite/shotgunMoveSprite.show()
			$attackSprite/shotgunAttackSprite.show()
		ENEMY_TYPE.assault:
			shotCooldown.wait_time = 0.5
			$movementSprite/assaultMoveSprite.show()
			$attackSprite/assaultAttackSprite.show()

func regularShoot():
	shootAudio.play()
	spawnBullet(shotPosition.global_position, rotation)
	
func shotgunShoot():
	shootAudio.play()
	spawnBullet(shotPosition.global_position, rotation)
	spawnBullet(shotPosition.global_position, rotation + shotgunSpread)
	spawnBullet(shotPosition.global_position, rotation - shotgunSpread)

func assaultShoot():
	spawnBullet(shotPosition.global_position, rotation)
	
func shoot():
	if shotCooldown.is_stopped():
		shotCooldown.start()
		match currentType:
			ENEMY_TYPE.regular:
				regularShoot()
			ENEMY_TYPE.assault:
				regularShoot()
			ENEMY_TYPE.shotgun:
				shotgunShoot()

func _physics_process(delta):
	if checkPlayerVisible.get_collider() is KinematicBody2D:
		showAttack()
		shoot()
		move_and_slide(getPathToPlayer() * speedWhileShooting)
	else:
		showMovement()
		move_and_slide(getPathToPlayer() * speed)

