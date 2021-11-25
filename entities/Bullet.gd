extends RigidBody2D
class_name Bullet

export (bool) var isFromEnemy := false
onready var muzSprite := $muzSprite
onready var collisionSprite := $CollisionSprite
onready var playerShootSprite := $playerShootSprite
onready var enemyShootSprite := $enemyShootSprite
var speed = 200
var dmg = 1

func _ready():
	if isFromEnemy:
		set_collision_layer_bit(5, true)
		enemyShootSprite.show()
	else: # is from player
		set_collision_mask_bit(3, true)
		set_collision_layer_bit(6, true)
		playerShootSprite.show()

func fire(fromPosition, fromRotiation, toRotation):
	position = fromPosition
	rotation_degrees = fromRotiation
	apply_impulse(Vector2(),Vector2(speed, 0).rotated(toRotation))

func _on_Node2D_body_entered(body: Node2D):
	if body is KinematicBody2D:
		body.hit(self, dmg)
	
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
