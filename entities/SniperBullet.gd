extends RigidBody2D

onready var line := $Line2D
onready var animations := $AnimationPlayer
var speed = 600


func fire(fromPosition, fromRotiation, toRotation):
	position = fromPosition
	rotation_degrees = fromRotiation
	apply_impulse(Vector2(),Vector2(speed, 0).rotated(toRotation))


func explode():
	sleeping = true
	line.hide()
	animations.play("explode")
	yield(animations, "animation_finished")
	queue_free()

func _on_SniperBullet_body_entered(body):
	explode()


func _on_destroyTimer_timeout():
	queue_free()
