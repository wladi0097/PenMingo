extends "res://entities/enemies/EnemyBase.gd"

onready var afterAttackCooldown := $AfterAttackCooldown
onready var afterAttackAnimation := $afterAttackAnimation
var speed = 110
var afterAttackKnockback = 30

func _physics_process(delta):
	if afterAttackCooldown.is_stopped():
		move_and_slide(getPathToPlayer() * speed)

func _on_PlayerEnter_body_entered(body):
	afterAttackAnimation.play("afterAttack")
	afterAttackCooldown.start()
	body.hit(self, 1)
	move_and_collide(body.global_position.direction_to(self.global_position).normalized() * afterAttackKnockback)
