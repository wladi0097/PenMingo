extends KinematicBody2D

onready var navigation : Navigation2D = find_parent("Navigation2D")
onready var animations := $AnimationPlayer
onready var movementSprite := $movementSprite
onready var attackSprite := $attackSprite

export var hp = 10
export var hitKnockBack = 2
export var lookAtPlayer = true

var isAttacking = false

func _ready():
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

func hit(bullet, dmg):
	animations.play("hit")
	move_and_collide(bullet.global_position.direction_to(self.global_position).normalized() * hitKnockBack)
	
	hp -= dmg
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
	else:
		movementSprite.scale.y = 1
		attackSprite.scale.y = 1
