extends RigidBody2D
class_name SniperBullet

onready var line := $Line2D
onready var animations := $AnimationPlayer
onready var muzSprite := $muzSprite
onready var explosionArea := $ExplosionArea
var isExplodingBullet = false # set by player unlock
var explosiveBulletDmgModifier = 0.7

func fire(fromPosition, fromRotiation, toRotation):
	position = fromPosition
	rotation_degrees = fromRotiation
	apply_impulse(Vector2(),Vector2(CURRENT_RUN.currentFlamingoBulletSpeed, 0).rotated(toRotation))

func explode():
	sleeping = true
	line.hide()
	animations.play("explode")
	
	for body in explosionArea.get_overlapping_bodies():
		if body is KinematicBody2D:
			body.hit(self, floor(CURRENT_RUN.currentFlamingoDamage * explosiveBulletDmgModifier))
	
	yield(animations, "animation_finished")
	queue_free()
	
func regularShot(body):
	if body is KinematicBody2D:
		body.hit(self, CURRENT_RUN.currentFlamingoDamage)
	queue_free()

func _on_SniperBullet_body_entered(body):
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.EXPLOSIVE_SHOT):
		explode()
	else:
		regularShot(body)

func _on_destroyTimer_timeout():
	queue_free()

func _on_MuzTimer_timeout():
	muzSprite.hide()
