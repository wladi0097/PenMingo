extends "res://entities/enemies/EnemyBase.gd"

enum ENEMY_TYPE {regular, shotgun}
export(ENEMY_TYPE) var currentType = ENEMY_TYPE.regular

var speed = 50
var speedWhileShooting = 15
var shotgunSpread =  0.3
onready var checkPlayerVisible := $checkPlayerVisible
onready var shotCooldown := $shotCooldown
onready var shotPosition := $shotPosition
onready var regularBullet := preload("res://entities/attacks/Bullet.tscn")
onready var shootAudio := $shootAudio

func _ready():
	if currentType == ENEMY_TYPE.regular:
		$movementSprite/regularMoveSprite.show()
		$attackSprite/regularAttackSprite.show()
	else:
		$movementSprite/shotgunMoveSprite.show()
		$attackSprite/shotgunAttackSprite.show()

func spawnBullet(new_rotation):
	var bullet_instance = regularBullet.instance()
	bullet_instance.isFromEnemy = true
	bullet_instance.fire(shotPosition.global_position, self.rotation_degrees, new_rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	shootAudio.play()

func regularShoot():
	spawnBullet(rotation)
	
func shotgunShoot():
	spawnBullet(rotation)
	spawnBullet(rotation + shotgunSpread)
	spawnBullet(rotation - shotgunSpread)
	
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

