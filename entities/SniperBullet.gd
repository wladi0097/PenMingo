extends RigidBody2D

onready var line := $Line2D
onready var animations := $AnimationPlayer
onready var muzSprite := $muzSprite
onready var explosionArea := $ExplosionArea
var dmg = 5
var speed = 600

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
	queue_free()

func _on_SniperBullet_body_entered(body):
	explode()

func _on_destroyTimer_timeout():
	queue_free()

func _on_MuzTimer_timeout():
	muzSprite.hide()
