extends CanvasLayer


func _on_NewGameButton_button_down():
	CURRENT_RUN.startNewRun()
	queue_free()
