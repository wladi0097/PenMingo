extends KinematicBody2D

var knockback = 2
onready var animations := $AnimationPlayer

func _ready():
	pass # Replace with function body.

func hit(bullet: Node2D):
	animations.play("hit")
	move_and_collide(bullet.global_position.direction_to(self.global_position).normalized() * knockback)
	pass
