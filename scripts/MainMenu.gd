extends CanvasLayer

onready var buttonHoverAudio := $ButtonHover
onready var buttonClickAudio := $ButtonClick

func _on_NewGameButton_button_down():
	buttonClickAudio.play()
	yield(buttonClickAudio, "finished")
	
	LOADING_TRANSITION.start()
	yield(LOADING_TRANSITION, "animation_finished")
	
	CURRENT_RUN.startNewRun()
	queue_free()

func _on_ContinueButton_mouse_entered():
	pass

func _on_NewGameButton_mouse_entered():
	buttonHoverAudio.play()

func _on_OptionsButton_mouse_entered():
	buttonHoverAudio.play()
