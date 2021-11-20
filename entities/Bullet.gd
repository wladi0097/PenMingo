extends RigidBody2D

onready var muzSprite := $muzSprite
onready var collisionSprite := $CollisionSprite
onready var mainSprite := $Sprite
var speed = 200

func fire(fromPosition, fromRotiation, toRotation):
	position = fromPosition
	rotation_degrees = fromRotiation
	apply_impulse(Vector2(),Vector2(speed, 0).rotated(toRotation))

func _on_Node2D_body_entered(body: Node2D):
	if body is KinematicBody2D:
		body.hit(self)
	
	collisionSprite.show()
	mainSprite.hide()
	$collisionDieTimer.start()

func _on_Timer_timeout():
	self.queue_free()

func _on_muz_timeout():
	muzSprite.hide()

func _on_collisionDieTimer_timeout():
	self.queue_free()
