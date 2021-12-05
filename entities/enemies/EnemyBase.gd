extends KinematicBody2D

onready var regularBullet := preload("res://entities/attacks/Bullet.tscn")
onready var navigation : Navigation2D = find_parent("Navigation2D")
onready var animations := $AnimationPlayer
onready var movementSprite := $movementSprite
onready var attackSprite := $attackSprite
onready var hpBox := $hpBox
onready var hpBar := $hpBox/hpBar
onready var bossHpBox := $CanvasLayer/BossHpBox
onready var bossHpBar := $CanvasLayer/BossHpBox/ProgressBar
var originalHpBoxPosition
var rng = RandomNumberGenerator.new()

export var hp = 10
export var hitKnockBack = 2
export var lookAtPlayer = true
export var displayName = ""
export var isBoss = false

var isAttacking = false
var maxHp = hp

func _ready():
	if isBoss:
		bossHpBox.show()
		hpBox.hide()
	
	maxHp = hp
	originalHpBoxPosition = hpBox.position
	showMovement()

func die():
	find_parent("FightStage").enemyDied()
	queue_free()

func showAttack():
	isAttacking = true
	movementSprite.hide()
	attackSprite.show()
	
func showMovement():
	isAttacking = false
	movementSprite.show()
	attackSprite.hide()

func getPathToPlayer():
	var path = navigation.get_simple_path(self.position, GLOBAL.player.position)
	path.remove(0)
	return self.position.direction_to(path[0]).normalized()
	
func getAngleToPlayer():
	var path = navigation.get_simple_path(self.position, GLOBAL.player.position)
	path.remove(0)
	return path[0].angle_to_point(self.position)

func updateHpBar():
	var percent = (hp * 100 / maxHp) / 10
	prints(hp, maxHp)
	
	hpBar.points = [Vector2.ZERO, Vector2(percent, 0)]
	bossHpBar.value = percent

func hit(bullet, dmg):
	animations.play("hit")
	
	if hitKnockBack > 0:
		move_and_collide(bullet.global_position.direction_to(self.global_position).normalized() * hitKnockBack)
	
	hp -= dmg
	updateHpBar()
	if hp <= 0:
		die()

func _physics_process(delta):
	if lookAtPlayer:
		rotateSpriteAccoringToPlayer()
		look_at(GLOBAL.player.global_position)
	
func rotateSpriteAccoringToPlayer():
	if GLOBAL.player.global_position.x < global_position.x:
		movementSprite.scale.y = -1
		attackSprite.scale.y = -1
		hpBox.position.y = -originalHpBoxPosition.y
	else:
		movementSprite.scale.y = 1
		attackSprite.scale.y = 1
		hpBox.position.y = originalHpBoxPosition.y
		
func spawnBullet(from, to, selfRotation = self.rotation_degrees):
	var bullet_instance = regularBullet.instance()
	bullet_instance.isFromEnemy = true
	bullet_instance.fire(from, selfRotation, to)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
