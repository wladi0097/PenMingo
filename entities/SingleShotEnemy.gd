extends KinematicBody2D

var knockback = 2
var speed = 100
var hp = 10
onready var animations := $AnimationPlayer
onready var checkPlayerVisible := $checkPlayerVisible
onready var shotCooldown := $shotCooldown
onready var shotPosition := $shotPosition
onready var regularBullet := preload("res://entities/Bullet.tscn")
onready var navigation : Navigation2D = find_parent("Navigation2D")

func _ready():
	pass

func hit(bullet: Node2D, dmg):
	animations.play("hit")
	move_and_collide(bullet.global_position.direction_to(self.global_position).normalized() * knockback)
	
	hp -= dmg
	if hp <= 0:
		queue_free()

func shoot():
	var bullet_instance = regularBullet.instance()
	bullet_instance.isFromEnemy = true
	bullet_instance.fire(shotPosition.global_position, self.rotation_degrees, rotation)
	get_tree().get_root().call_deferred("add_child", bullet_instance)

func followUntilPlayerIsVisible(delta):
	var path = navigation.get_simple_path(self.position, GLOBAL.player.position)
	path.remove(0)
	move_and_slide(self.position.direction_to(path[0]).normalized() * speed)

func _physics_process(delta):
	look_at(GLOBAL.player.global_position)
	
	var collision = checkPlayerVisible.get_collider()
	if collision is KinematicBody2D:
		if shotCooldown.is_stopped():
			shotCooldown.start()
			shoot()
	else:
		followUntilPlayerIsVisible(delta)
