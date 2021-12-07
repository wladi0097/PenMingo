extends RigidBody2D
class_name SniperBullet

onready var line := $Line2D
onready var animations := $AnimationPlayer
onready var muzSprite := $muzSprite
onready var explosionArea := $ExplosionArea
var isExplodingBullet = false # set by player unlock
var explosiveBulletDmgModifier = 0.7
var bulletFollowsMouseStrngth = 70
var originalDirection

func _physics_process(_delta):
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.FLAMINGO_BULLET_FOLLOWS_MOUSE):
		linear_velocity = GLOBAL.player.global_position.direction_to(get_global_mouse_position()).normalized() * CURRENT_RUN.currentFlamingoBulletSpeed
		look_at(global_position + linear_velocity)

func fire(fromPosition, fromRotiation, toRotation):
	position = fromPosition
	rotation_degrees = fromRotiation
	originalDirection = Vector2(CURRENT_RUN.currentFlamingoBulletSpeed, 0).rotated(toRotation)
	apply_impulse(Vector2(), originalDirection)

func explode(dmg):
	sleeping = true
	line.hide()
	animations.play("explode")
	
	for body in explosionArea.get_overlapping_bodies():
		if body is KinematicBody2D:
			body.hit(self, floor(dmg * explosiveBulletDmgModifier))
	
	yield(animations, "animation_finished")
	queue_free()
	
func regularShot(body, dmg):
	if body is KinematicBody2D:
		body.hit(self, dmg)
	queue_free()

func _on_SniperBullet_body_entered(body):
	var dmg = CURRENT_RUN.currentFlamingoDamage
			
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.CRIT_DMG) && randi() % 100 <= 3: # is crit
		dmg *= 2
	
	if CURRENT_RUN.hasUpgrade(CURRENT_RUN.UPGRADES.EXPLOSIVE_SHOT):
		explode(dmg)
	else:
		regularShot(body, dmg)

func _on_destroyTimer_timeout():
	queue_free()

func _on_MuzTimer_timeout():
	muzSprite.hide()
