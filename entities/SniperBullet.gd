extends RigidBody2D

onready var line := $Line2D
onready var animations := $AnimationPlayer
onready var muzSprite := $muzSprite
onready var explosionArea := $ExplosionArea
var dmg = 5
var speed = 600
var isExplodingBullet = false # set by player unlock

func fire(fromPosition, fromRotiation, toRotation):
	position = fromPosition
	rotation_degrees = fromRotiation
	apply_impulse(Vector2(),Vector2(speed, 0).rotated(toRotation))

func explode():
	sleeping = true
	line.hide()
	animations.play("explode")
	
	for body in explosionArea.get_overlapping_bodies():
		if body is KinematicBody2D:
			body.hit(self, dmg)
	
	yield(animations, "animation_finished")
	
func regularShot(body):
	if body is KinematicBody2D:
		body.hit(self, dmg)
	queue_free()

func _on_SniperBullet_body_entered(body):
	if isExplodingBullet:
		explode()
	else:
		regularShot(body)

func _on_destroyTimer_timeout():
	queue_free()

func _on_MuzTimer_timeout():
	muzSprite.hide()
