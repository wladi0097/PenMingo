extends Node2D

func _ready():
	$AnimationPlayer.play("drop")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func hitEntitesInRange():
	for entity in $Area2D.get_overlapping_bodies():
		if entity.has_method("hit"):
			entity.hit(self, 1)
