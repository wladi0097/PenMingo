extends Node2D

func _ready():
	$AnimationPlayer.play("drop")
	yield($AnimationPlayer, "animation_finished")
	for entities in $Area2D.get_overlapping_bodies():
		entities.hit(self, 1)
	queue_free()
