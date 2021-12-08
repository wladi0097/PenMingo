extends KinematicBody2D

onready var regularBullet := preload("res://entities/attacks/Bullet.tscn")
onready var bomb := preload("res://entities/attacks/Bomb.tscn")
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
var isDead = false

func _ready():
	if isBoss:
		$CanvasLayer/BossHpBox/name.text = displayName
		bossHpBox.show()
		hpBox.hide()
	
	maxHp = hp
	originalHpBoxPosition = hpBox.position
	showMovement()

func die():
	if !isDead:
		isDead = true
		CURRENT_RUN.thisRunKilledEnemies += 1
		find_parent("FightStage").enemyDied(self)
		queue_free()

func showAttack():
	isAttacking = true
	movementSprite.hide()
	attackSprite.show()
	
func showMovement():
	isAttacking = false
	movementSprite.show()
	attackSprite.hide()

func getPathToPlayer() -> Vector2:
	var path = navigation.get_simple_path(self.position, GLOBAL.player.position)
	if path.size() > 0:
		path.remove(0)
		return self.position.direction_to(path[0]).normalized()
	else:
		return Vector2.ZERO
	
func getAngleToPlayer():
	var path = navigation.get_simple_path(self.position, GLOBAL.player.position)	
	if path.size() > 0:
		path.remove(0)
		return path[0].angle_to_point(self.position)
	else:
		return 0.0
	
	

func updateHpBar():
	var percent = (hp * 100 / maxHp) / 10
	
	hpBar.points = [Vector2.ZERO, Vector2(percent, 0)]
	bossHpBar.value = percent

func hit(bullet, dmg):
	CURRENT_RUN.thisRunDealthDamage += dmg
	animations.play("hit")
	
	if hitKnockBack > 0:
		move_and_collide(bullet.global_position.direction_to(self.global_position).normalized() * hitKnockBack)
	
	hp -= dmg
	updateHpBar()
	if hp <= 0:
		die()

func _physics_process(_delta):
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
	
func spawnBomb(spawnPosition = GLOBAL.player.global_position):
	var bomb_instance = bomb.instance()
	bomb_instance.global_position = spawnPosition
	get_tree().get_root().call_deferred("add_child", bomb_instance)
