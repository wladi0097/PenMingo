extends KinematicBody2D

var speed = 120
var shotKnockback = 10
var afterAttackKnockback = 30
var hp = 5
onready var navigation : Navigation2D = find_parent("Navigation2D")
onready var afterAttackCooldown := $AfterAttackCooldown
onready var animations := $AnimationPlayer

func die():
	var parent = get_parent()
	if parent.has_method('enemyDied'):
		parent.enemyDied()
	queue_free()

func followUntilPlayerIsVisible(delta):
	var path = navigation.get_simple_path(self.position, GLOBAL.player.position)
	path.remove(0)
	move_and_slide(self.position.direction_to(path[0]).normalized() * speed)

func _physics_process(delta):
	if afterAttackCooldown.is_stopped():
		followUntilPlayerIsVisible(delta)
		look_at(GLOBAL.player.global_position)
	
func hit(bullet, dmg):
	animations.play("hit")
	move_and_collide(bullet.global_position.direction_to(self.global_position).normalized() * shotKnockback)
	
	hp -= dmg
	if hp <= 0:
		die()
	
func _on_PlayerEnter_body_entered(body):
	animations.play("afterAttack")
	afterAttackCooldown.start()
	body.hit(self, 1)
	move_and_collide(body.global_position.direction_to(self.global_position).normalized() * afterAttackKnockback)
