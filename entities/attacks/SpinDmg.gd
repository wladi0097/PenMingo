extends Node2D

onready var checkEnemies := $CheckEnemies
onready var animations := $AnimationPlayer

func _ready():
	animations.play("spin")

func _on_destorySelfTimer_timeout():
	queue_free()

func _on_affectDamageTimer_timeout():
	for enemy in checkEnemies.get_overlapping_bodies():
		if enemy.has_method("hit"):
			enemy.hit(self, 1)
