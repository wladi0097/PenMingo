extends RigidBody2D

var dmg = 4
onready var animations := $AnimationPlayer
onready var explosionArea := $ExplosionArea

func explode():
	animations.play("explode")
	
	for body in explosionArea.get_overlapping_bodies():
		if body is KinematicBody2D:
			if body.name == "Player":
				body.hit(self, 1)
			else:
				body.hit(self, dmg)
	
	yield(animations, "animation_finished")
	queue_free()

func _on_ExplosiveBarrel_body_entered(body):
	if body is Bullet || body is SniperBullet:
		explode()
