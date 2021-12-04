extends RigidBody2D
class_name Bullet

export (bool) var isFromEnemy := false
onready var muzSprite := $muzSprite
onready var collisionSprite := $CollisionSprite
onready var playerShootSprite := $playerShootSprite
onready var enemyShootSprite := $enemyShootSprite
onready var destroySelfTimer := $destorySelfTimer
var enemySpeed = 100
var initialRotationDirection
var isBouncyBullet = false

func _ready():
	if isFromEnemy:
		set_collision_layer_bit(5, true)
		enemyShootSprite.show()
		destroySelfTimer.wait_time = 5
	else: # is from player
		if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.PENGUIN_BOUNCY_BULLET):
			isBouncyBullet = true
		
		destroySelfTimer.wait_time = CURRENT_RUN.currentPenguinRange
		set_collision_mask_bit(3, true)
		set_collision_layer_bit(6, true)
		playerShootSprite.show()
		
	destroySelfTimer.start()
	
func fire(fromPosition, fromRotiation, toRotation):
	position = fromPosition
	rotation_degrees = fromRotiation
	initialRotationDirection = toRotation
	
	var speed
	if isFromEnemy:
		speed = enemySpeed
	else: 
		speed = CURRENT_RUN.currentPenguinBulletSpeed
	
	apply_impulse(Vector2(),Vector2(speed, 0).rotated(toRotation))

func _on_Node2D_body_entered(body: Node2D):
	if body is KinematicBody2D:
		if isFromEnemy:
			body.hit(self, 1)
		else:
			var dmg = CURRENT_RUN.currentPenguinDamage
			
			if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.CRIT_DMG) && randi() % 100 <= 3: # is crit
				dmg *= 2
			
			body.hit(self, floor(dmg))
		removeBulletWithEffects()
	else:
		if !isBouncyBullet:
			removeBulletWithEffects()


func _physics_process(delta):
	if isBouncyBullet &&  linear_velocity.length() < 100:
		linear_velocity = linear_velocity.normalized() * 100

func removeBulletWithEffects():
	collisionSprite.show()
	playerShootSprite.hide()
	enemyShootSprite.hide()
	$collisionDieTimer.start()

func _on_Timer_timeout():
	self.queue_free()

func _on_muz_timeout():
	muzSprite.hide()

func _on_collisionDieTimer_timeout():
	self.queue_free()
		
