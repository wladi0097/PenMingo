extends "res://entities/enemies/EnemyBase.gd"

var speed = 50
var rotationSpeed = 0.015
var afterAttackKnockback = 50
onready var attackTimer := $AttackTimer
onready var attackAnimations := $attackAnimationPlayer
onready var attackRange := $StartAttack
onready var waitAfterAttack := $waitAfterAttack

func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	if waitAfterAttack.is_stopped():
		move_and_slide(getPathToPlayer() * speed)
		rotation = lerp_angle(rotation, getAngleToPlayer(), rotationSpeed)
		rotateSpriteAccoringToPlayer()
	
func damageEntitiesInFrontOfShield():
	for entity in attackRange.get_overlapping_bodies():
		if entity.has_method("hit"):
			waitAfterAttack.start()
			move_and_collide(entity.global_position.direction_to(self.global_position).normalized() * afterAttackKnockback)
			entity.hit(self, 1)

func _on_StartAttack_body_entered(body):
	if attackTimer.is_stopped():
		attackTimer.start()
		attackAnimations.play("attack")
