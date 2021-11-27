extends Node2D


func _on_StartRun_body_entered(body):
	CURRENT_RUN.startNewRun()
	queue_free()
