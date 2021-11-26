extends KinematicBody2D

enum ENEMY_TYPE {regular, shotgun}
export(ENEMY_TYPE) var currentType = ENEMY_TYPE.regular

var knockback = 2
var speed = 50
var hp = 10
var shotgunSpread =  0.3
onready var animations := $AnimationPlayer
onready var checkPlayerVisible := $checkPlayerVisible
onready var shotCooldown := $shotCooldown
onready var shotPosition := $shotPosition
onready var regularBullet := preload("res://entities/Bullet.tscn")
onready var navigation : Navigation2D = find_parent("Navigation2D")
onready var regularAttackSprite := $regularAttackSprite
onready var regulatMoveSprite := $regularMoveSprite
onready var shotgunMoveSprite := $shotgunMoveSprite
onready var shotgunAttackprite := $shotgunAttackSprite
onready var shootAudio := $shootAudio

func die():
	find_parent("FightStage").enemyDied()
	queue_free()

func hit(bullet: Node2D, dmg):
	animations.play("hit")
	move_and_collide(bullet.global_position.direction_to(self.global_position).normalized() * knockback)
	
	hp -= dmg
	if hp <= 0:
		die()

func shoot(new_rotation):
	var bullet_instance = regularBullet.instance()
	bullet_instance.isFromEnemy = true
	bullet_instance.fire(shotPosition.global_position, self.rotation_degrees, new_rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	shootAudio.play()


func regularShoot():
	shoot(rotation)
	
func shotgunShoot():
	shoot(rotation)
	shoot(rotation + shotgunSpread)
	shoot(rotation - shotgunSpread)

func followUntilPlayerIsVisible(delta):
	var path = navigation.get_simple_path(self.position, GLOBAL.player.position)
	path.remove(0)
	move_and_slide(self.position.direction_to(path[0]).normalized() * speed)

func _physics_process(delta):
	rotateSpriteAccoringToPlayer()
	look_at(GLOBAL.player.global_position)
	
	var collision = checkPlayerVisible.get_collider()
	if collision is KinematicBody2D:
		if currentType == ENEMY_TYPE.regular:
			regularAttackSprite.show()
			regulatMoveSprite.hide()
		else:
			shotgunAttackprite.show()
			shotgunMoveSprite.hide()
		
		if shotCooldown.is_stopped():
			shotCooldown.start()
			if currentType == ENEMY_TYPE.regular:
				regularShoot()
			elif currentType == ENEMY_TYPE.shotgun:
				shotgunShoot()
	else:
		if currentType == ENEMY_TYPE.regular:
			regularAttackSprite.hide()
			regulatMoveSprite.show()
		else:
			shotgunAttackprite.hide()
			shotgunMoveSprite.show()
		
		followUntilPlayerIsVisible(delta)
		
func rotateSpriteAccoringToPlayer():
	if GLOBAL.player.global_position.x < global_position.x:
		regularAttackSprite.scale.y = -1
		regulatMoveSprite.scale.y = -1
		shotgunAttackprite.scale.y = -1
		shotgunMoveSprite.scale.y = -1
	else:
		regularAttackSprite.scale.y = 1
		regulatMoveSprite.scale.y = 1
		shotgunAttackprite.scale.y = 1
		shotgunMoveSprite.scale.y = 1
